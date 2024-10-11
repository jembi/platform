"use client";

import { useState } from "react";
import { Sidebar } from "@/components/Sidebar";
import { RecipesPage } from "@/components/recipes-page";
import { PackagesDeployedPage } from "@/components/packages-deployed-page";
import { AddonsPage } from "@/components/addons-page";

export default function Home() {
  const [selectedPage, setSelectedPage] = useState("recipes");

  const renderPage = () => {
    switch (selectedPage) {
      case "recipes":
        return <RecipesPage />;
      case "addons":
        return <AddonsPage />; // Add this case
      case "packagesDeployed":
        return <PackagesDeployedPage />;
      default:
        return <div>Page not implemented yet</div>;
    }
  };

  return (
    <div className="flex">
      <Sidebar onPageSelect={setSelectedPage} selectedPage={selectedPage} />
      <main className="flex-1 ml-64">{renderPage()}</main>
    </div>
  );
}
