export interface LottieFile {
  key: string;
  content: any;
}

export const importLottieFiles = async (folder: string): Promise<LottieFile[]> => {
  let modules;
  if (folder === "desktop") {
    modules = import.meta.glob("@/assets/lottie/desktop/*.json");
  } else if (folder === "mobile") {
    modules = import.meta.glob("@/assets/lottie/mobile/*.json");
  } else throw new Error(`Unsupported folder: ${folder}`);

  if (modules) {
    const lottieFiles: LottieFile[] = [];

    for (const path in modules) {
      const content = await modules[path]();
      lottieFiles.push({
        key: path,
        content: (content as { default: any }).default,
      });
    }

    return lottieFiles;
  } else throw new Error(`Unsupported folder: ${folder}`);
};
