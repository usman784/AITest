import 'package:audioplayers/audioplayers.dart';
import 'package:arrow_flow/core/constants/app_assets.dart';

/// The set of available sound packs.
enum SoundPack { arcade, nature, asmr, scifi, silent }

/// All discrete sound effects used during gameplay.
enum SoundEffect {
  tapSuccess,
  tapError,
  levelComplete,
  arrowExitUp,
  arrowExitDown,
  arrowExitLeft,
  arrowExitRight,
  hintChime,
  lifeLost,
}

/// The available looping ambient tracks.
enum AmbientTrack { lofi, forest, rain, spaceDrone }

/// Manages all audio playback for Arrow Flow.
///
/// Maintains two [AudioPlayer] instances — one for short SFX and one for the
/// looping ambient track — so that they do not interrupt each other.
///
/// Instantiate via the Riverpod [audioServiceProvider] defined in
/// `lib/core/di/providers.dart`.
class AudioService {
  AudioService({
    required AudioPlayer sfxPlayer,
    required AudioPlayer ambientPlayer,
  })  : _sfxPlayer = sfxPlayer,
        _ambientPlayer = ambientPlayer;

  final AudioPlayer _sfxPlayer;
  final AudioPlayer _ambientPlayer;

  SoundPack _currentPack = SoundPack.arcade;
  double _sfxVolume = 1.0;
  double _musicVolume = 0.3;
  bool _sfxEnabled = true;
  bool _musicEnabled = true;

  // ── Public API ────────────────────────────────────────────────────────────────

  /// Switches to [pack] and optionally pre-warms the players.
  Future<void> loadSoundPack(SoundPack pack) async {
    _currentPack = pack;
  }

  /// Plays [effect] once using the SFX player.
  ///
  /// Silently no-ops when SFX are disabled or [_currentPack] is
  /// [SoundPack.silent].
  Future<void> playSfx(SoundEffect effect) async {
    if (!_sfxEnabled || _currentPack == SoundPack.silent) return;
    final path = _sfxPath(effect);
    if (path.isEmpty) return;
    await _sfxPlayer.setVolume(_sfxVolume);
    await _sfxPlayer.play(AssetSource(path));
  }

  /// Starts looping [track] on the ambient player.
  Future<void> playAmbient(AmbientTrack track) async {
    if (!_musicEnabled) return;
    final path = _ambientPath(track);
    if (path.isEmpty) return;
    await _ambientPlayer.setVolume(_musicVolume);
    await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
    await _ambientPlayer.play(AssetSource(path));
  }

  /// Stops the currently playing ambient track.
  Future<void> stopAmbient() async {
    await _ambientPlayer.stop();
  }

  /// Sets SFX playback volume in the range [0.0, 1.0].
  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    _sfxPlayer.setVolume(_sfxVolume);
  }

  /// Sets ambient music volume in the range [0.0, 1.0].
  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _ambientPlayer.setVolume(_musicVolume);
  }

  /// Enables or disables SFX playback.
  void setSfxEnabled(bool enabled) {
    _sfxEnabled = enabled;
    if (!enabled) _sfxPlayer.stop();
  }

  /// Enables or disables ambient music playback.
  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      _ambientPlayer.stop();
    }
  }

  /// Releases underlying [AudioPlayer] resources.
  void dispose() {
    _sfxPlayer.dispose();
    _ambientPlayer.dispose();
  }

  // ── Private helpers ───────────────────────────────────────────────────────────

  /// Returns the asset path for [effect] in the active [_currentPack].
  ///
  /// Paths returned here must be rooted at the `assets/` folder and must
  /// match the entries in `pubspec.yaml`.
  String _sfxPath(SoundEffect effect) {
    switch (_currentPack) {
      case SoundPack.arcade:
        return _arcadeSfxPath(effect);
      case SoundPack.nature:
        return _natureSfxPath(effect);
      case SoundPack.asmr:
        return _asmrSfxPath(effect);
      case SoundPack.scifi:
        return _scifiSfxPath(effect);
      case SoundPack.silent:
        return '';
    }
  }

  String _arcadeSfxPath(SoundEffect effect) {
    switch (effect) {
      case SoundEffect.tapSuccess:
        return AppAssets.arcadeTapPop;
      case SoundEffect.tapError:
        return AppAssets.arcadeBuzzError;
      case SoundEffect.levelComplete:
        return AppAssets.arcadeWinChime;
      case SoundEffect.arrowExitUp:
        return AppAssets.arcadeWhooshUp;
      case SoundEffect.arrowExitDown:
        return AppAssets.arcadeWhooshDown;
      case SoundEffect.arrowExitLeft:
        return AppAssets.arcadeWhooshLeft;
      case SoundEffect.arrowExitRight:
        return AppAssets.arcadeWhooshRight;
      case SoundEffect.hintChime:
        return AppAssets.arcadeWinChime;
      case SoundEffect.lifeLost:
        return AppAssets.arcadeLifeLost;
    }
  }

  String _natureSfxPath(SoundEffect effect) {
    switch (effect) {
      case SoundEffect.tapSuccess:
        return AppAssets.natureTapLeaf;
      case SoundEffect.tapError:
        return AppAssets.natureBuzzError;
      case SoundEffect.levelComplete:
        return AppAssets.natureWinChime;
      case SoundEffect.arrowExitUp:
        return AppAssets.natureWhooshUp;
      case SoundEffect.arrowExitDown:
        return AppAssets.natureWhooshDown;
      case SoundEffect.arrowExitLeft:
        return AppAssets.natureWhooshLeft;
      case SoundEffect.arrowExitRight:
        return AppAssets.natureWhooshRight;
      case SoundEffect.hintChime:
        return AppAssets.natureWinChime;
      case SoundEffect.lifeLost:
        return AppAssets.natureBuzzError;
    }
  }

  String _asmrSfxPath(SoundEffect effect) {
    switch (effect) {
      case SoundEffect.tapSuccess:
        return AppAssets.asmrTapPop;
      case SoundEffect.tapError:
        return AppAssets.asmrBuzzError;
      case SoundEffect.levelComplete:
        return AppAssets.asmrWinChime;
      case SoundEffect.hintChime:
        return AppAssets.asmrWinChime;
      default:
        return AppAssets.asmrTapPop;
    }
  }

  String _scifiSfxPath(SoundEffect effect) {
    switch (effect) {
      case SoundEffect.tapSuccess:
        return AppAssets.scifiTapPop;
      case SoundEffect.tapError:
        return AppAssets.scifiBuzzError;
      case SoundEffect.levelComplete:
        return AppAssets.scifiWinChime;
      case SoundEffect.arrowExitUp:
        return AppAssets.scifiWhooshUp;
      case SoundEffect.arrowExitDown:
        return AppAssets.scifiWhooshDown;
      case SoundEffect.arrowExitLeft:
        return AppAssets.scifiWhooshLeft;
      case SoundEffect.arrowExitRight:
        return AppAssets.scifiWhooshRight;
      case SoundEffect.hintChime:
        return AppAssets.scifiWinChime;
      case SoundEffect.lifeLost:
        return AppAssets.scifiBuzzError;
    }
  }

  /// Returns the asset path for the given ambient [track].
  String _ambientPath(AmbientTrack track) {
    switch (track) {
      case AmbientTrack.lofi:
        return AppAssets.ambientLofi;
      case AmbientTrack.forest:
        return AppAssets.ambientForest;
      case AmbientTrack.rain:
        return AppAssets.ambientRain;
      case AmbientTrack.spaceDrone:
        return AppAssets.ambientSpaceDrone;
    }
  }
}
