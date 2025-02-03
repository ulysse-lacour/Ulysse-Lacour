<template>
  <div class="name">
    <h1 id="first_name">
      <div class="name_letter">u</div>
      <div class="name_letter">l</div>
      <div class="name_letter">y</div>
      <div class="name_letter">s</div>
      <div class="name_letter">s</div>
      <div class="name_letter">e</div>
    </h1>
    <h1 id="last_name">
      <div class="name_letter">l</div>
      <div class="name_letter">a</div>
      <div class="name_letter">c</div>
      <div class="name_letter">o</div>
      <div class="name_letter">u</div>
      <div class="name_letter">r</div>
    </h1>
  </div>
</template>

<script setup lang="ts">
  onMounted(() => {
    nameAnimation();
  });

  const nameAnimation = () => {
    const nameLetters = document.querySelectorAll(".name_letter");
    const name = document.querySelector(".name");

    const animateLetters = useGsap.timeline({
      paused: true,
      reversed: true,
    });

    animateLetters
      .to(nameLetters, {
        scale: 1.2,
        ease: "power1.out",
      })
      .to(
        nameLetters,
        {
          x: "random(-2, 2)",
          y: "random(-5, 5)",
          ease: "none",
        },
        "<"
      );

    if (name) {
      name.addEventListener("mouseenter", () => animateLetters.play(0));
      name.addEventListener("mouseleave", () => animateLetters.reverse());
    }
  };
</script>

<style scoped>
  h1 {
    margin: 1rem;
  }

  .name {
    z-index: 1;
    position: absolute;
    top: 45%;
    left: 50%;
    -webkit-transform: translate(-50%, -50%);
    transform: translate(-50%, -50%);
    font-family: "Director";
    font-size: 3rem;
    line-height: 2rem;
    -webkit-transition: font-size 0.5s;
    -moz-transition: font-size 0.5s;
    -ms-transition: font-size 0.5s;
    -o-transition: font-size 0.5s;
    transition: font-size 0.5s;
    cursor: default;
  }

  #first_name,
  #last_name {
    display: flex;
    justify-content: center;
  }

  .name_letter {
    opacity: 0;
    animation: appear 2s ease forwards;
  }

  @keyframes appear {
    0% {
      opacity: 0;
    }
    50% {
      opacity: 0;
    }
    100% {
      opacity: 1;
    }
  }

  @media screen and (max-width: 640px) {
    .name {
      font-size: 3rem;
      top: 50%;
      -webkit-transform: translate(-50%, -50%) scale(0.75);
      transform: translate(-50%, -50%) scale(0.75);
    }
  }

  @media (min-width: 640px) and (max-width: 1024px) {
    .name {
      top: 47.5%;
    }
  }
</style>
