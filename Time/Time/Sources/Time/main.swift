//
//  main.swift
//  TIme
//
//  Created by Petar Lemajic on 12/23/18.
//  Copyright © 2018 Petar Lemajic. All rights reserved.
//

import Foundation
import NIO

final class Server {

    struct Configuration {
        var host: String? = nil
        var port: Int = 1313
        var backlog: Int = 256
        var eventLoopGroup: EventLoopGroup? = nil
    }

    let configuration: Configuration
    let eventLoopGroup: EventLoopGroup
    var serverChannel: Channel?

    init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
        self.eventLoopGroup = configuration.eventLoopGroup ?? MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    }

    func listenAndWait() {
        listen()
        do { try serverChannel?.closeFuture.wait() }
        catch { print("[!] ERROR: Failed to wait on server:", error) }
    }

    func listen() {
        let bootstrap = makeBootstrap()

        do {
            let address: SocketAddress

            if let host = configuration.host {
                address = try SocketAddress.newAddressResolving(host: host, port: configuration.port)
            } else {
                var addr = sockaddr_in()
                addr.sin_port = in_port_t(configuration.port).bigEndian
                address = SocketAddress(addr, host: "*")
            }
            serverChannel = try bootstrap.bind(to: address).wait()

            if let addr = serverChannel?.localAddress {
                print("[+] Server running on:", addr)
            } else {
                print("[!] ERROR: server reported no local address?")
            }
        } catch let error as NIO.IOError {
            print("[!] ERROR: failed to start server, errno:",
                error.errnoCode, "\n",
                error.localizedDescription)
        }
        catch {
            print("[!] ERROR: failed to start server:", type(of: error), error)
        }
    }

    func makeBootstrap() -> ServerBootstrap {
        let reuseAddrOpt = ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET),
                                                 SO_REUSEADDR)
        let bootstrap = ServerBootstrap(group: eventLoopGroup)
            // Specify backlog and enable SO_REUSEADDR for the server itself
            .serverChannelOption(ChannelOptions.backlog,
                                 value: Int32(configuration.backlog))
            .serverChannelOption(reuseAddrOpt, value: 1)
            
            // Set the handlers that are applied to the accepted Channels
            .childChannelInitializer { channel in
                channel.pipeline
                    .add(name: "Daytime",
                         handler: DaytimeHandler())
            }
            
            // Enable TCP_NODELAY and SO_REUSEADDR for the accepted Channels
            .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY),
                                value: 1)
            .childChannelOption(reuseAddrOpt, value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
        
        return bootstrap
    }
}

let server = Server()
server.listenAndWait()
