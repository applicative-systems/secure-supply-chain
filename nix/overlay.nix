final: prev: {
  db-reader = prev.callPackage ../packages/db-reader { };
  db-writer = prev.callPackage ../packages/db-writer { };
}
