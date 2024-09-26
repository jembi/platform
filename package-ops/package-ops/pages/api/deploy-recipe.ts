import { NextApiRequest, NextApiResponse } from "next";
import { exec } from "child_process";
import { promisify } from "util";

const execAsync = promisify(exec);

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method !== "POST") {
    return res.status(405).json({ message: "Method Not Allowed" });
  }

  const { recipeId } = req.body;

  if (!recipeId) {
    return res.status(400).json({ message: "Recipe ID is required" });
  }

  try {
    const { stdout, stderr } = await execAsync(
      `/usr/local/bin/instant package init -p ${recipeId} --dev`,
      {
        cwd: "/home/ryanc/git/platform",
        shell: "/bin/bash",
      }
    );

    console.log("Command output:", stdout);
    if (stderr) {
      console.error("Command error:", stderr);
    }

    res
      .status(200)
      .json({ success: true, message: "Recipe deployed successfully" });
  } catch (error) {
    console.error("Error deploying recipe:", error);
    res
      .status(500)
      .json({ success: false, message: "Failed to deploy recipe" });
  }
}
