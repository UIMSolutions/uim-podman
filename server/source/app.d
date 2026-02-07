module app;

import uim.podman.desktop.server;

version (SERVER_APP):

int main(string[] args) {
  runRestServer();
  return 0;
}
