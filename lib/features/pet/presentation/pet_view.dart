import 'package:material_ui/material_ui.dart';
import 'package:petbridge/features/pet/presentation/pet_painter.dart';
import 'package:petbridge/features/pet/presentation/pet_spec.dart';

export 'package:petbridge/features/pet/presentation/pet_spec.dart' show PetPose;

/// Turns all [PetView] animation off when false. Tests set it to false in
/// `test/flutter_test_config.dart` so screens that show a pet can still
/// `pumpAndSettle`; pets then paint a still frame, as with `animate: false`.
@visibleForTesting
bool debugPetViewAnimations = true;

const _idlePeriod = Duration(milliseconds: 2400);
const _sleepPeriod = Duration(milliseconds: 3400);
const _cuteDuration = Duration(milliseconds: 1200);

/// One pet drawn in code. Breathes in [pose]; when [cuteTick] grows it plays
/// the 1.2 s cute one-shot and returns to [pose] (a new tick restarts it).
/// `animate: false` paints a still frame (share poster). Animation stops when
/// [TickerMode] is off.
class PetView extends StatefulWidget {
  const new({
    required this.petType,
    super.key,
    this.size = 160,
    this.pose = PetPose.idle,
    this.cuteTick = 0,
    this.animate = true,
  });

  final String petType;
  final double size;

  /// `idle` or `sleep`; `cute` here is treated as `idle` plus a one-shot.
  final PetPose pose;
  final int cuteTick;
  final bool animate;

  @override
  State<PetView> createState() => _PetViewState();
}

class _PetViewState extends State<PetView> with TickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: _periodFor(widget.pose),
  );
  late final AnimationController _cute = AnimationController(
    vsync: this,
    duration: _cuteDuration,
  );

  bool get _animating => widget.animate && debugPetViewAnimations;

  PetPose get _basePose =>
      widget.pose == PetPose.sleep ? PetPose.sleep : PetPose.idle;

  static Duration _periodFor(PetPose pose) =>
      pose == PetPose.sleep ? _sleepPeriod : _idlePeriod;

  @override
  void initState() {
    super.initState();
    _syncBreath();
    if (widget.pose == PetPose.cute) _playCute();
  }

  @override
  void didUpdateWidget(PetView old) {
    super.didUpdateWidget(old);
    final period = _periodFor(widget.pose);
    if (_breath.duration != period) _breath.duration = period;
    if (old.animate != widget.animate || old.pose != widget.pose) {
      _syncBreath();
    }
    if (widget.cuteTick > old.cuteTick ||
        (widget.pose == PetPose.cute && old.pose != PetPose.cute)) {
      _playCute();
    }
  }

  void _syncBreath() {
    if (_animating) {
      _breath.repeat();
    } else {
      _breath
        ..stop()
        ..value = 0;
      _cute
        ..stop()
        ..value = 0;
    }
  }

  void _playCute() {
    if (!_animating) return;
    _cute.forward(from: 0);
  }

  @override
  void dispose() {
    _breath.dispose();
    _cute.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spec = specFor(widget.petType);
    return SizedBox.square(
      dimension: widget.size,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge([_breath, _cute]),
          builder: (context, _) => CustomPaint(
            size: Size.square(widget.size),
            painter: PetPainter(
              spec: spec,
              pose: _basePose,
              phase: _breath.value,
              cuteProgress: _cute.isAnimating ? _cute.value : -1,
            ),
          ),
        ),
      ),
    );
  }
}
