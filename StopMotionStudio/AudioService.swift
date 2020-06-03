//
//  AudioService.swift
//  StopMotionStudio
//
//  Created by Shuntaro Kasatani on 6/1/20.
//  Copyright © 2020 Shuntaro Kasatani. All rights reserved.
//

import UIKit
import AVFoundation

class AudioService {
    // バッファ
    var buffer: UnsafeMutableRawPointer?
    // オーディオキューオブジェクト
    var audioQueueObject: AudioQueueRef?
    // 再生時のパケット数
    let numPacketsToRead: UInt32 = 1024
    // 録音時のパケット数
    let numPacketsToWrite: UInt32 = 1024
    // 再生/録音時の読み出し/書き込み位置
    var startingPacketCount: UInt32 = 0
    // 最大パケット数。（サンプリングレート x 秒数）
    var maxPacketCount: UInt32 = 0
    // パケットのバイト数
    let bytesPerPacket: UInt32 = 2
    // 録音時間（＝再生時間）
    let seconds: UInt32 = 10
    // オーディオストリームのフォーマット
    var audioFormat: AudioStreamBasicDescription {
        return AudioStreamBasicDescription(mSampleRate: 48000.0,  // サンプリング周波数
            mFormatID: kAudioFormatLinearPCM,  // フォーマットID（リニアPCM, MP3, AAC etc）
            mFormatFlags: AudioFormatFlags(kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked),  // フォーマットフラグ（エンディアン, 整数or浮動小数点数）
            mBytesPerPacket: 2,  // １パケットのバイト数（データ読み書き単位）
            mFramesPerPacket: 1,  // １パケットのフレーム数
            mBytesPerFrame: 2,  // １フレームのバイト数
            mChannelsPerFrame: 1,  // １フレームのチャンネル数
            mBitsPerChannel: 16,  // １チャンネルのビット数
            mReserved: 0)
    }
    // 書き出し/読み出し用のデータ
    var data: Data?
    
    private func prepareForRecord() {
        var audioFormat = self.audioFormat
        
        AudioQueueNewInput(&audioFormat,
                           AQAudioQueueInputCallback,
                           unsafeBitCast(self, to: UnsafeMutableRawPointer.self),
                           CFRunLoopGetCurrent(),
                           CFRunLoopMode.commonModes.rawValue,
                           0,
                           &audioQueueObject)
        
        startingPacketCount = 0;
        var buffers = Array<AudioQueueBufferRef?>(repeating: nil, count: 3)
        let bufferByteSize: UInt32 = numPacketsToWrite * audioFormat.mBytesPerPacket
        
        for bufferIndex in 0 ..< buffers.count {
            AudioQueueAllocateBuffer(audioQueueObject!, bufferByteSize, &buffers[bufferIndex])
            AudioQueueEnqueueBuffer(audioQueueObject!, buffers[bufferIndex]!, 0, nil)
        }
    }
    
    func AQAudioQueueInputCallback(inUserData: UnsafeMutableRawPointer?, inAQ: AudioQueueRef, inBuffer: AudioQueueBufferRef, inStartTime: UnsafePointer<AudioTimeStamp>, inNumberPacketDescriptions: UInt32, inPacketDescs: UnsafePointer<AudioStreamPacketDescription>?) {
        let audioService = unsafeBitCast(inUserData!, to:AudioService.self)
        audioService.writePackets(inBuffer: inBuffer)
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, nil);
        
        if (audioService.maxPacketCount <= audioService.startingPacketCount) {
            audioService.stopRecord()
        }
    }
    
    func writePackets(inBuffer: AudioQueueBufferRef) {
        var numPackets: UInt32 = (inBuffer.pointee.mAudioDataByteSize / bytesPerPacket)
        if ((maxPacketCount - startingPacketCount) < numPackets) {
            numPackets = (maxPacketCount - startingPacketCount)
        }
        
        if 0 < numPackets {
            memcpy(buffer?.advanced(by: Int(bytesPerPacket * startingPacketCount)),
                   inBuffer.pointee.mAudioData,
                   Int(bytesPerPacket * numPackets))
            startingPacketCount += numPackets
        }
    }
    
    func startRecord() {
        guard audioQueueObject == nil else  { return }
        prepareForRecord()
        let err: OSStatus = AudioQueueStart(audioQueueObject!, nil)
        print("error: \(err.description)")
    }
    
    func stopRecord() {
        data = Data(bytes: buffer!, count: Int(maxPacketCount * bytesPerPacket))
        AudioQueueStop(audioQueueObject!, true)
        AudioQueueDispose(audioQueueObject!, true)
        audioQueueObject = nil
    }
    
}
