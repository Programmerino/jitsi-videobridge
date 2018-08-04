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

import java.nio.ByteBuffer
import kotlin.properties.Delegates


internal class BitBufferRtpPacket : RtpPacket() {
    override var buf: ByteBuffer by Delegates.notNull()
    override var header: RtpHeader by Delegates.notNull()
    override var payload: ByteBuffer by Delegates.notNull()

    companion object {
        fun fromBuffer(buf: ByteBuffer): RtpPacket {
            return BitBufferRtpPacket().apply {
                this.buf = buf.slice()
                header = RtpHeader.fromBuffer(buf)
                payload = buf.slice()
            }
        }
        fun fromValues(receiver: BitBufferRtpPacket.() -> Unit) = BitBufferRtpPacket().apply(receiver)
    }
}
