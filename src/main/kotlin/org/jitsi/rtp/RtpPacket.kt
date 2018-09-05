/*
 * Copyright @ 2018 Atlassian Pty Ltd
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.jitsi.rtp

import org.jitsi.rtp.extensions.clone
import org.jitsi.rtp.util.BufferView
import java.nio.ByteBuffer

// would https://github.com/kotlin-graphics/kotlin-unsigned be useful?

// https://tools.ietf.org/html/rfc3550#section-5.1
// 0                   1                   2                   3
// 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
// |V=2|P|X|  CC   |M|     PT      |       sequence number         |
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
// |                           timestamp                           |
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
// |           synchronization source (SSRC) identifier            |
// +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
// |            contributing source (CSRC) identifiers             |
// |                             ....                              |
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

open class RtpPacket : Packet {
    private var buf: ByteBuffer? = null
    var header: RtpHeader
    var payload: ByteBuffer
    override val size: Int
        get() = header.size + payload.limit()

    constructor(buf: ByteBuffer) {
        this.buf = buf
        this.header = RtpHeader(buf)
        this.payload = (buf.position(header.size) as ByteBuffer).slice().duplicate()
    }

    constructor(
        header: RtpHeader = RtpHeader(),
        payload: ByteBuffer = ByteBuffer.allocate(0)
    ) {
        this.header = header
        this.payload = payload
    }

    override fun getBuffer(): ByteBuffer {
        if (this.buf == null) {
            this.buf = ByteBuffer.allocate(header.size + payload.limit())
        }
        this.buf!!.rewind()
        this.buf!!.put(header.getBuffer())
        this.buf!!.put(payload)

        this.buf!!.rewind()
        return this.buf!!
    }

    override fun clone(): Packet {
        return RtpPacket(getBuffer().clone())
    }

    override fun toString(): String {
        return with (StringBuffer()) {
            appendln("RTP packet")
            appendln("size: $size")
            append(header.toString())
            appendln("payload size: ${payload.limit()}")
            toString()
        }
    }
}

