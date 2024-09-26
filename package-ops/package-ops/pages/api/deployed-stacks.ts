import { NextApiRequest, NextApiResponse } from "next";
import Docker from "dockerode";

interface Service {
  name: string;
  replicas: number;
}

interface Stack {
  name: string;
  services: Service[];
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method !== "GET") {
    return res.status(405).json({ message: "Method not allowed" });
  }

  try {
    const docker = new Docker();
    const stacks: Stack[] = [];

    // Get all services
    const services = await docker.listServices();

    // Group services by stack
    const stackMap = new Map<string, Service[]>();
    for (const service of services) {
      const stackName = service.Spec.Labels["com.docker.stack.namespace"];
      if (stackName) {
        if (!stackMap.has(stackName)) {
          stackMap.set(stackName, []);
        }
        stackMap.get(stackName)!.push({
          name: service.Spec.Name,
          replicas: service.Spec.Mode.Replicated?.Replicas || 0,
        });
      }
    }

    // Convert map to array of Stack objects
    Array.from(stackMap).forEach(([name, services]) => {
      stacks.push({ name, services });
    });

    res.status(200).json(stacks);
  } catch (error) {
    console.error("Error fetching deployed stacks:", error);
    res.status(500).json({ message: "Error fetching deployed stacks" });
  }
}
