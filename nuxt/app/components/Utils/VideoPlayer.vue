<template>
  <video ref="videoPlayer" class="video-js"></video>
</template>

<script>
  import videojs from "video.js";

  export default {
    name: "VideoPlayer",
    props: {
      options: {
        type: Object,
        default() {
          return {};
        },
      },
    },
    data() {
      return {
        player: null,
        playerError: null,
      };
    },
    mounted() {
      try {
        this.player = videojs(this.$refs.videoPlayer, this.options, () => {
          this.player.on("error", (error) => {
            this.playerError = error;
            console.error("Video.js player error:", error);
          });
        });
      } catch (error) {
        console.error("Failed to initialize video player:", error);
        this.playerError = error;
      }
    },
    beforeUnmount() {
      if (this.player) {
        try {
          this.player.dispose();
        } catch (error) {
          console.error("Error disposing video player:", error);
        }
      }
    },
  };
</script>
