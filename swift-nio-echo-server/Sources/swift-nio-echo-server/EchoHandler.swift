//
// Created by Andrey Syvrachev on 2019-03-06.
//

import Foundation
import NIO
import NIOConcurrencyHelpers


extension Thread {
    var sname: String {
        return name ?? ""
    }
}

func log(_ s:String) {
    print("[\(Thread.current.sname)] \(s)" )
}

private let handlersCount = Atomic<UInt32>(value:0)
//private let activeCount = Atomic<UInt32>(value:0)

private let index = Atomic<UInt32>(value:0)

internal final class EchoHandler: ChannelInboundHandler {
    public typealias InboundIn = ByteBuffer
    public typealias OutboundOut = ByteBuffer

    private let id = index.add(1)

    init() {
        _ = handlersCount.add(1)
        log("EchoHandler:init   \(id):\(handlersCount.load())")

    }

    deinit {
        _ = handlersCount.sub(1)
        log("EchoHandler:deinit \(id):\(handlersCount.load())")
    }

    func userInboundEventTriggered(ctx: ChannelHandlerContext, event: Any) {
        log("EchoHandler:userInboundEventTriggered \(id):\(handlersCount.load())")
        ctx.close(promise: nil)
    }

    public func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        // As we are not really interested getting notified on success or failure we just pass nil as promise to
        // reduce allocations.
        ctx.write(data, promise: nil)
    }

//    func channelActive(ctx: ChannelHandlerContext) {
//        _ = activeCount.add(1)
//        log("EchoHandler:channelActive   \(id):\(handlersCount.load()):\(activeCount.load())")
//    }
//
//    func channelInactive(ctx: ChannelHandlerContext) {
//        _ = activeCount.sub(1)
//        log("EchoHandler:channelInactive   \(id):\(handlersCount.load()):\(activeCount.load())")
//    }

    // Flush it out. This can make use of gathering writes if multiple buffers are pending
    public func channelReadComplete(ctx: ChannelHandlerContext) {

        // As we are not really interested getting notified on success or failure we just pass nil as promise to
        // reduce allocations.
        ctx.flush()
    }

    public func errorCaught(ctx: ChannelHandlerContext, error: Error) {
      //  log("error: \(error)")

        // As we are not really interested getting notified on success or failure we just pass nil as promise to
        // reduce allocations.
        ctx.close(promise: nil)
    }
}
