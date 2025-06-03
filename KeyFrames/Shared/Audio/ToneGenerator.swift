import AVFoundation

public class ToneGenerator {
	private let engine = AVAudioEngine()
	private var player: AVAudioPlayerNode = AVAudioPlayerNode()

	private var sourceNode: AVAudioSourceNode!
	private var theta: Float = 0
	private let sampleRate: Double = 44100
	private var frequency: Float { defaultFrequency * pitch }

	private var pitch: Float = 1
	private let defaultFrequency: Float = 130

	public init() {
		let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!

		sourceNode = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
			let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
			let delta = (2 * Float.pi * self.frequency) / Float(self.sampleRate)

			for frame in 0..<Int(frameCount) {
				let sampleVal = sin(self.theta)
				self.theta += delta
				if self.theta > 2 * Float.pi {
					self.theta -= 2 * Float.pi
				}
				for buffer in ablPointer {
					let buf = buffer.mData!.assumingMemoryBound(to: Float.self)
					buf[frame] = sampleVal * self.player.volume // Volume
				}
			}
			return noErr
		}

		player.volume = 0

		engine.attach(sourceNode)
		engine.attach(player)

		engine.connect(player, to: engine.mainMixerNode, format: nil)
		engine.connect(sourceNode, to: engine.mainMixerNode, format: format)

		try? engine.start()
	}

	public func startEngine() {
		try? engine.start()
	}

	public func stopEngine() {
		engine.stop()
	}

	public func play() {
		player.play()
		player.volume = 0.7
	}

	public func pause() {
		player.pause()
		player.volume = 0
		pitch = 1
	}

	public func set(pitch: Float) {
		self.pitch = 1 + pitch
	}
}
