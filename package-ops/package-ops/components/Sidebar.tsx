import Link from "next/link";
import {
  Package2Icon,
  LayoutGridIcon,
  LayersIcon,
  UsersIcon,
  SettingsIcon,
} from "./Icons";

interface SidebarProps {
  onPageSelect: (page: string) => void;
  selectedPage: string;
}

export function Sidebar({ onPageSelect, selectedPage }: SidebarProps) {
  const navItems = [
    { id: "recipes", label: "Recipes", icon: LayoutGridIcon },
    { id: "packagesDeployed", label: "Packages Deployed", icon: LayersIcon },
    { id: "team", label: "Team", icon: UsersIcon },
    { id: "settings", label: "Settings", icon: SettingsIcon },
  ];

  return (
    <aside className="fixed inset-y-0 left-0 z-10 flex w-64 flex-col border-r bg-background sm:flex">
      <div className="flex h-[60px] items-center px-6">
        <Link
          href="#"
          className="flex items-center gap-2 font-semibold"
          prefetch={false}
        >
          <Package2Icon className="h-6 w-6" />
          <span className="">Package Ops</span>
        </Link>
      </div>
      <nav className="flex-1 px-4 py-2">
        <div className="grid gap-2">
          {navItems.map((item) => (
            <button
              key={item.id}
              onClick={() => onPageSelect(item.id)}
              className={`flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors hover:text-foreground ${
                selectedPage === item.id
                  ? "bg-accent text-accent-foreground"
                  : "text-muted-foreground hover:bg-accent hover:text-accent-foreground"
              }`}
            >
              <item.icon className="h-5 w-5" />
              <span>{item.label}</span>
            </button>
          ))}
        </div>
      </nav>
    </aside>
  );
}
