import type { ReactNode } from "react";
import { tvCredits, reelArchiveUrl } from "../data/tvCredits";
import { SectionLabel } from "./About";

function ExternalLink({
  href,
  children,
  className = "",
}: {
  href: string;
  children: ReactNode;
  className?: string;
}) {
  return (
    <a
      href={href}
      target="_blank"
      rel="noopener noreferrer"
      className={`inline-flex items-center gap-1 transition hover:text-[#F1D592] ${className}`}
    >
      {children}
    </a>
  );
}

export function TvWork() {
  return (
    <section id="tv-work" className="border-t border-[#C5A059]/15 bg-[#0B1220] px-6 py-20">
      <div className="mx-auto max-w-6xl">
        <SectionLabel number="02" title="TV & Broadcast Work" />
        <p className="mt-6 max-w-2xl text-slate-400">
          Press play on the work. Every credit links to a live sample — sizzle reels, promos, and
          segments across network and branded production.
        </p>

        <div className="mt-12 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
          {tvCredits.map((credit) => (
            <article
              key={credit.project}
              className={`group flex flex-col rounded-lg border bg-[#1E293B] p-6 transition hover:border-[#C5A059]/60 ${
                credit.featured
                  ? "border-[#C5A059]/50 ring-1 ring-[#C5A059]/20"
                  : "border-[#C5A059]/20"
              }`}
            >
              <span className="text-[10px] font-semibold uppercase tracking-[0.3em] text-[#C5A059]">
                {credit.network}
              </span>
              <h3 className="font-display mt-2 text-xl font-bold text-white group-hover:text-[#F1D592]">
                {credit.project}
              </h3>
              <p className="mt-1 text-xs uppercase tracking-wider text-slate-500">{credit.role}</p>
              <p className="mt-3 flex-1 text-sm leading-relaxed text-slate-400">{credit.proof}</p>
              <ExternalLink
                href={credit.href}
                className="mt-4 text-sm font-medium uppercase tracking-wider text-[#C5A059]"
              >
                Watch ↗
              </ExternalLink>
            </article>
          ))}
        </div>

        <div className="mt-10 text-center">
          <ExternalLink
            href={reelArchiveUrl}
            className="inline-block rounded border border-[#C5A059]/40 px-6 py-3 text-sm font-medium uppercase tracking-[0.2em] text-[#F1D592] hover:bg-[#C5A059]/10"
          >
            Full Reel Archive — shannonjlove.tv ↗
          </ExternalLink>
        </div>
      </div>
    </section>
  );
}
