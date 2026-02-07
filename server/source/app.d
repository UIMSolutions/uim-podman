module app;

import uim.podman.server;

version (SERVER_APP):

int main(string[] args) {
  runRestServer();
  return 0;
}
