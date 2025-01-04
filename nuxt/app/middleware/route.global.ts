export default defineNuxtRouteMiddleware(() => {
  interface ScrollState {
    scroll?: { x: number; y: number };
  }

  const nuxtApp = useNuxtApp();
  const unsubscribe = nuxtApp.hook("page:finish", () => {
    try {
      const state = history.state as ScrollState;
      const scroll = state.scroll;

      if (scroll) {
        window.scrollTo({
          left: scroll.x,
          top: scroll.y,
          behavior: "smooth",
        });
      } else {
        window.scrollTo({
          top: 0,
          behavior: "smooth",
        });
      }
    } catch (error) {
      console.error("Failed to restore scroll position:", error);
    }
  });

  // Cleanup hook subscription when middleware is destroyed
  onUnmounted(() => {
    unsubscribe();
  });
});
