<!-- eslint-disable vue/no-multiple-template-root -->
<template>
  <div class="flex min-h-screen flex-col justify-between">
    <Header />

    <main class="content-wrapper">
      <slot />
    </main>

    <Footer />
  </div>
</template>
