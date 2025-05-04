#include <boost/asio.hpp>
#include <iostream>
#include <cstdlib>
#include <pqxx/pqxx>
#include <string>
#include <memory>


using boost::asio::ip::tcp;
using namespace std::placeholders;

class Session : public std::enable_shared_from_this<Session> {
public:
    Session(tcp::socket socket, const std::string& db_conn)
        : socket_(std::move(socket)), db_conn_(db_conn), buffer_(1024, 0) {}

    void start() {
        do_read();
    }

private:
    void do_read() {
        auto self(shared_from_this());
        boost::asio::async_read_until(socket_, boost::asio::dynamic_buffer(input_), '\n',
            [this, self](boost::system::error_code ec, std::size_t length) {
                if (!ec) {
                    std::string line = input_.substr(0, length - 1); // remove newline
                    input_.erase(0, length);

                    try {
                        pqxx::connection c(db_conn_);
                        pqxx::work txn(c);
                        txn.exec("INSERT INTO testcounter (content) VALUES ($1)", pqxx::params{line});
                        txn.commit();
                        std::cout << "Inserted: " << line << std::endl;
                    } catch (const std::exception& e) {
                        std::cerr << "DB error: " << e.what() << std::endl;
                    }

                    do_read();
                }
            });
    }

    tcp::socket socket_;
    std::string db_conn_;
    std::string input_;
    std::vector<char> buffer_;
};

class Server {
public:
    Server(boost::asio::io_context& io_context, short port, const std::string& db_conn)
        : acceptor_(io_context, tcp::endpoint(tcp::v4(), port)),
          db_conn_(db_conn) {
        do_accept();
    }

private:
    void do_accept() {
        acceptor_.async_accept(
            [this](boost::system::error_code ec, tcp::socket socket) {
                if (!ec) {
                    std::make_shared<Session>(std::move(socket), db_conn_)->start();
                }
                do_accept();
            });
    }

    tcp::acceptor acceptor_;
    std::string db_conn_;
};

void db_init(const std::string& conn_str) {
    try {
        pqxx::connection c(conn_str);
        pqxx::work txn(c);

        txn.exec(R"sql(
            CREATE TABLE IF NOT EXISTS testcounter (
                id SERIAL PRIMARY KEY,
                content TEXT NOT NULL,
                date TIMESTAMP NOT NULL DEFAULT now()
            );
        )sql");

        txn.commit();
        std::cout << "Database initialized (table ensured)." << std::endl;
    } catch (const std::exception& e) {
        std::cerr << "Database init failed: " << e.what() << std::endl;
        throw; // rethrow to abort program if desired
    }
}


int main(int argc, char* argv[]) {
    try {
        if (argc != 2) {
            std::cerr << "Usage: cpp_async_db_writer <port>\n";
            return 1;
        }

        const char* conn_env = std::getenv("DATABASE_URL");
        if (!conn_env) {
            std::cerr << "DATABASE_URL environment variable not set.\n";
            return 1;
        }

        const std::string db_conn(conn_env);

        db_init(db_conn);

        boost::asio::io_context io_context;
        short port = std::stoi(argv[1]);

        Server server(io_context, port, db_conn);
        std::cout << "Server listening on port " << port << "\n";
        io_context.run();
    } catch (std::exception& e) {
        std::cerr << "Fatal error: " << e.what() << "\n";
    }

    return 0;
}
