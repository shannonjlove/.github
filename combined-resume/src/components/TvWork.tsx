import type { ReactNode } from "react";
import { tvCredits, reelArchiveUrl } from "../data/tvCredits";
import { youtubeThumbnail } from "../utils/youtube";
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
          Press play on the work. Every credit uses the official YouTube thumbnail from the linked
          video — sizzle reels, promos, and segments across network and branded production.
        </p>

        <div className="mt-12 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
          {tvCredits.map((credit) => {
            const thumb = youtubeThumbnail(credit.href);
            return (
              <article
                key={credit.project}
                className={`group flex flex-col overflow-hidden rounded-lg border bg-[#1E293B] transition hover:border-[#C5A059]/60 ${
                  credit.featured
                    ? "border-[#C5A059]/50 ring-1 ring-[#C5A059]/20"
                    : "border-[#C5A059]/20"
                }`}
              >
                <ExternalLink href={credit.href} className="relative block shrink-0">
                  <img
                    src={thumb}
                    alt={`${credit.project} — video thumbnail`}
                    loading="lazy"
                    className="aspect-video w-full object-cover transition duration-300 group-hover:brightness-110"
                  />
                  <span className="absolute inset-0 flex items-center justify-center bg-black/35 opacity-0 transition group-hover:opacity-100">
                    <span className="rounded-full border border-[#F1D592]/60 bg-[#0F172A]/80 px-4 py-2 text-xs font-semibold uppercase tracking-[0.2em] text-[#F1D592]">
                      Watch ↗
                    </span>
                  </span>
                </ExternalLink>

                <div className="flex flex-1 flex-col p-6">
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
                    Open on YouTube ↗
                  </ExternalLink>
                </div>
              </article>
            );
          })}
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
