#include "httpserver.h"

#include <cstdio>
#include <iostream>
#include <fstream>

#include "fmt/format.h"
#include "wpi/EventLoopRunner.h"
#include "wpi/HttpServerConnection.h"
#include "wpi/UrlParser.h"
#include "wpi/uv/Loop.h"
#include "wpi/uv/Tcp.h"
#include "frc/Filesystem.h"

namespace uv = wpi::uv;

class MyHttpServerConnection : public wpi::HttpServerConnection {
public:
  explicit MyHttpServerConnection(std::shared_ptr<uv::Stream> stream)
    : HttpServerConnection(stream)
  {}

protected:
  void ProcessRequest() override;
};


void MyHttpServerConnection::ProcessRequest() {
  fmt::print(stderr, "HTTP request: '{}'\n", m_request.GetUrl());
  wpi::UrlParser url{m_request.GetUrl(),
                     m_request.GetMethod() == wpi::HTTP_CONNECT};
  if (!url.IsValid()) {
    // failed to parse URL
    SendError(400);
    return;
  }

  std::string_view path;
  if (url.HasPath()) {
    path = url.GetPath();
  }

  std::string_view query;
  if (url.HasQuery()) {
    query = url.GetQuery();
  }


  // mhm yeah oh yeah boogy!!!.
  FILE* myfile = fopen((frc::filesystem::GetDeployDirectory() + "/example.txt").c_str(), "r");
  // get file size
  fseek(myfile, 0, SEEK_END);
  long stringlength = ftell(myfile);

  // read file to string.
  std::string mystring(stringlength, '\0');
  fseek(myfile, 0, SEEK_SET);
  fread(&mystring[0], sizeof(char), (size_t)stringlength, myfile);
  std::cout << mystring;
  fclose(myfile);

  const bool isGET = m_request.GetMethod() == wpi::HTTP_GET;
  if (isGET && path == "/") {
    // build HTML root page
    SendResponse(200, "OK", "text/html", mystring);
  } else {
    SendError(404, "Resource not found");
  }
}


wpi::EventLoopRunner loop;

void StartHTTPServer() {
  // Kick off the event loop on a separate thread
  loop.ExecAsync([](uv::Loop& loop) {
    auto tcp = uv::Tcp::Create(loop);

    auto printErrors = [](uv::Error err) {
      fmt::print(stderr, "SERVER ERROR: ({} {}) {}\n", err.code(), err.name(), err.str());
    };
    tcp->error.connect(printErrors);

    // bind to listen address and port
    tcp->Bind("", 2175);

    // when we get a connection, accept it and start reading
    tcp->connection.connect([srv = tcp.get()]{
      auto tcp = srv->Accept();
      if (!tcp) {
        return;
      }
      auto conn = std::make_shared<MyHttpServerConnection>(tcp);
      tcp->SetData(conn);
    });

    // start listening for incoming connections
    tcp->Listen();

    std::fputs("Listening on port 8080\n", stderr);
  });
}
