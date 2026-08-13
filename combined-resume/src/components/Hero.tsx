import { contact, navItems } from "../data/site";

export function Nav() {
  return (
    <nav className="sticky top-0 z-50 border-b border-[#C5A059]/20 bg-[#0F172A]/95 backdrop-blur-md no-print">
      <div className="mx-auto max-w-6xl px-6 py-4">
        <div className="flex items-center justify-between">
          <a href="#top" className="font-display text-lg tracking-tight text-[#F1D592]">
            Shannon<span className="text-white"> J. Love</span>
          </a>
          <ul className="hidden items-center gap-6 md:flex">
            {navItems.map((item) => (
              <li key={item.id}>
                <a
                  href={`#${item.id}`}
                  className="text-xs font-medium uppercase tracking-[0.2em] text-slate-400 transition-colors hover:text-[#F1D592]"
                >
                  {item.label}
                </a>
              </li>
            ))}
          </ul>
          <button
            type="button"
            onClick={() => window.print()}
            className="hidden rounded border border-[#C5A059]/40 px-3 py-1.5 text-xs uppercase tracking-wider text-[#F1D592] transition hover:bg-[#C5A059]/10 md:block"
          >
            Save PDF
          </button>
        </div>
        <ul className="mt-3 flex gap-4 overflow-x-auto md:hidden">
          {navItems.map((item) => (
            <li key={item.id} className="shrink-0">
              <a
                href={`#${item.id}`}
                className="text-[10px] font-medium uppercase tracking-[0.15em] text-slate-400"
              >
                {item.label}
              </a>
            </li>
          ))}
        </ul>
      </div>
    </nav>
  );
}

export function Hero() {
  return (
    <header id="top" className="relative overflow-hidden border-b border-[#C5A059]/20 px-6 py-16">
      <div className="pointer-events-none absolute inset-0 opacity-10">
        <div className="absolute left-[-10%] top-[-50%] h-[200%] w-[120%] bg-[radial-gradient(circle_at_center,#C5A059,transparent_70%)]" />
      </div>
      <div className="relative z-10 mx-auto max-w-6xl">
        <p className="mb-4 text-xs font-medium uppercase tracking-[0.35em] text-[#C5A059]">
          {contact.location} · 25 Years · Story-First
        </p>
        <h1 className="font-display text-5xl font-bold leading-tight md:text-7xl">
          <span className="gold-gradient">Shannon J. Love</span>
        </h1>
        <p className="mt-4 max-w-3xl text-lg text-slate-300 md:text-xl">{contact.title}</p>

        <div className="mt-8 flex flex-wrap gap-x-6 gap-y-2 text-sm text-slate-400">
          <a
            href={`mailto:${contact.email}`}
            className="transition hover:text-[#F1D592]"
          >
            {contact.email}
          </a>
          <a href={`tel:${contact.phone.replace(/-/g, "")}`} className="transition hover:text-[#F1D592]">
            {contact.phone}
          </a>
          <a
            href={contact.linkedin}
            target="_blank"
            rel="noopener noreferrer"
            className="transition hover:text-[#F1D592]"
          >
            LinkedIn ↗
          </a>
          <a
            href={contact.imdb}
            target="_blank"
            rel="noopener noreferrer"
            className="transition hover:text-[#F1D592]"
          >
            IMDb ↗
          </a>
        </div>

        <div className="no-print mt-12 overflow-hidden rounded-lg border-2 border-[#C5A059]/40 shadow-2xl">
          <div className="relative w-full" style={{ paddingBottom: "56.25%" }}>
            <iframe
              className="absolute inset-0 h-full w-full"
              src={`https://www.youtube.com/embed/${contact.highlightReelId}?rel=0`}
              title="Shannon J. Love — Highlight Reel"
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
              allowFullScreen
            />
          </div>
          <p className="bg-[#1E293B] py-2 text-center text-xs uppercase tracking-[0.3em] text-[#C5A059]">
            Highlight Reel
          </p>
        </div>
      </div>
    </header>
  );
}
