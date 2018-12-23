//
//  DaytimeHandler.swift
//  TIme
//
//  Created by Petar Lemajic on 12/23/18.
//  Copyright © 2018 Petar Lemajic. All rights reserved.
//

import Foundation
import NIO

public final class DaytimeHandler : ChannelInboundHandler {
    
    public typealias InboundIn = ByteBuffer
    public typealias OutboundOut = ByteBuffer
    
    public func channelActive(ctx: ChannelHandlerContext) {
        print("[+] New Channel, client address: ", ctx.channel.remoteAddress?.description ?? "-")
        let channel = ctx.channel
        var buffer = channel.allocator.buffer(capacity: 64)
        buffer.write(string: getTimestamp())
        ctx.writeAndFlush(NIOAny.init(buffer), promise: nil)
        ctx.close(promise: nil)
    }
    
    public func channelInactive(ctx: ChannelHandlerContext) {
        print("[+] Channel closed.")
    }
    
    public func errorCaught(ctx: ChannelHandlerContext, error: Error) {
        print("[!] ERROR:", error)
        ctx.close(promise: nil)
    }
    
    func getTimestamp() -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEEE, MMMM d, yyyy H:mm:ss-zzz"
        return formatter.string(from: now) + "\n"
    }
}
