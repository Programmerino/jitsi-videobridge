/*
 * Copyright @ 2018 - present 8x8, Inc.
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

package org.jitsi.rtp.rtcp

import io.kotlintest.matchers.types.shouldBeInstanceOf
import io.kotlintest.shouldThrow
import io.kotlintest.specs.ShouldSpec

class RtcpPacketTest : ShouldSpec() {

    init {
        "Parsing" {
            "a valid but unsupported RTCP packet" {
                val unsupportedRtcpData = org.jitsi.rtp.extensions.bytearray.byteArrayOf(
                    // V=2, PT=195, length = 2
                    0x80, 0xC3, 0x00, 0x02,
                    0x00, 0x00, 0x00, 0x00,
                    0x00, 0x00, 0x00, 0x00
                )
                should("return UnsupportedRtcpPacket") {
                    RtcpPacket.parse(unsupportedRtcpData, 0).shouldBeInstanceOf<UnsupportedRtcpPacket>()
                }
            }
            "an invalid RTCP packet" {
                val invalidRtcpData = byteArrayOf(
                    0x00, 0x00, 0x00, 0x00,
                    0x00, 0x00, 0x00, 0x00,
                    0x00, 0x00, 0x00, 0x00,
                    0x00, 0x00, 0x00, 0x00
                )
                should("throw an InvalidRtcpException") {
                    shouldThrow<InvalidRtcpException> {
                        RtcpPacket.parse(invalidRtcpData, 0)
                    }
                }
            }
        }
    }
}
