import 'package:uuid/uuid.dart';

class World3DObject {
	final String id;
	final String name;
	final String modelPath;
	final List<String> availableAnimations;

	double positionX;
	double positionY;
	double positionZ;

	double rotationX;
	double rotationY;
	double rotationZ;

	double scaleX;
	double scaleY;
	double scaleZ;

	String currentAnimation;
	bool animationPlaying;
	int animationLoopCount;

	World3DObject({
		String? id,
		required this.name,
		required this.modelPath,
		this.availableAnimations = const [],
		this.positionX = 0.0,
		this.positionY = 0.0,
		this.positionZ = 0.0,
		this.rotationX = 0.0,
		this.rotationY = 0.0,
		this.rotationZ = 0.0,
		this.scaleX = 1.0,
		this.scaleY = 1.0,
		this.scaleZ = 1.0,
		this.currentAnimation = '',
		this.animationPlaying = false,
		this.animationLoopCount = -1,
	}) : id = id ?? const Uuid().v4();

	World3DObject copyWith({
		String? name,
		List<String>? availableAnimations,
		double? positionX,
		double? positionY,
		double? positionZ,
		double? rotationX,
		double? rotationY,
		double? rotationZ,
		double? scaleX,
		double? scaleY,
		double? scaleZ,
		String? currentAnimation,
		bool? animationPlaying,
		int? animationLoopCount,
	}) {
		return World3DObject(
			id: id,
			name: name ?? this.name,
			modelPath: modelPath,
			availableAnimations: availableAnimations ?? this.availableAnimations,
			positionX: positionX ?? this.positionX,
			positionY: positionY ?? this.positionY,
			positionZ: positionZ ?? this.positionZ,
			rotationX: rotationX ?? this.rotationX,
			rotationY: rotationY ?? this.rotationY,
			rotationZ: rotationZ ?? this.rotationZ,
			scaleX: scaleX ?? this.scaleX,
			scaleY: scaleY ?? this.scaleY,
			scaleZ: scaleZ ?? this.scaleZ,
			currentAnimation: currentAnimation ?? this.currentAnimation,
			animationPlaying: animationPlaying ?? this.animationPlaying,
			animationLoopCount: animationLoopCount ?? this.animationLoopCount,
		);
	}
}