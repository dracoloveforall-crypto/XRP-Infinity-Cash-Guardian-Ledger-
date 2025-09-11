// SoundPlayer.qml
import QtQuick 6.0
import QtMultimedia

Item {
    id: soundPlayer

    function playSound(soundFile) {
        if (!soundFile || soundFile === "") return;

        try {
            // Korrekter Import für Qt 6
            var audio = Qt.createQmlObject(`
            import QtMultimedia
            MediaPlayer {
                source: "${soundFile}"
                audioOutput: AudioOutput {
                    volume: 0.7
                }
                onPlaybackStateChanged: {
                    if (playbackState === MediaPlayer.StoppedState) {
                        destroy();
                    }
                }
            }
            `, soundPlayer, "ConfigSoundPlayer");

            audio.play();
        } catch (error) {
            console.error("Error playing sound in config:", error, soundFile);
        }
    }
}
