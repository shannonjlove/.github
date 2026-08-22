import { contact } from "../data/site";
import {
  publishedEssays,
  writingArchiveUrl,
  writingSamples,
} from "../data/writingSamples";
import { SectionLabel } from "./About";

export function Writing() {
  return (
    <section id="writing" className="px-6 py-20">
      <div className="mx-auto max-w-6xl">
        <SectionLabel number="03" title="The Pen — Writing & Speech" />
        <p className="mt-6 max-w-2xl text-slate-400">
          Political copy, public-health PSAs, long-form essays, civic correspondence, TV treatments,
          and stage work — each sample hosted with full text.
        </p>

        <div className="mt-12 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
          {writingSamples.map((sample) => (
            <a
              key={sample.href}
              href={sample.href}
              target="_blank"
              rel="noopener noreferrer"
              className="group flex flex-col rounded-lg border border-[#C5A059]/20 bg-[#1E293B] p-6 transition hover:border-[#C5A059]/60"
            >
              <span className="text-[10px] font-semibold uppercase tracking-[0.3em] text-[#C5A059]">
                {sample.category}
              </span>
              <h3 className="font-display mt-2 text-lg font-bold text-white group-hover:text-[#F1D592]">
                {sample.title}
              </h3>
              <p className="mt-3 flex-1 text-sm leading-relaxed text-slate-400">
                {sample.description}
              </p>
              <span className="mt-4 text-sm font-medium uppercase tracking-wider text-[#C5A059]">
                Read Sample ↗
              </span>
            </a>
          ))}
        </div>

        <div className="mt-16">
          <h3 className="text-xs font-semibold uppercase tracking-[0.3em] text-[#C5A059]">
            Published Essays
          </h3>
          <ul className="mt-6 space-y-3">
            {publishedEssays.map((essay) => (
              <li key={essay.title}>
                <a
                  href={essay.href}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="group flex flex-wrap items-baseline gap-2 text-slate-300 transition hover:text-[#F1D592]"
                >
                  <span className="font-display text-lg">{essay.title}</span>
                  {essay.note && (
                    <span className="text-xs uppercase tracking-wider text-slate-500">
                      — {essay.note} ↗
                    </span>
                  )}
                </a>
              </li>
            ))}
          </ul>
          <div className="mt-8 flex flex-wrap gap-4">
            <a
              href={writingArchiveUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="rounded border border-[#C5A059]/40 px-6 py-3 text-sm font-medium uppercase tracking-[0.2em] text-[#F1D592] transition hover:bg-[#C5A059]/10"
            >
              Browse All Writing Samples ↗
            </a>
            <a
              href={contact.medium}
              target="_blank"
              rel="noopener noreferrer"
              className="rounded border border-slate-600 px-6 py-3 text-sm font-medium uppercase tracking-[0.2em] text-slate-400 transition hover:border-[#C5A059]/40 hover:text-[#F1D592]"
            >
              Medium Archive ↗
            </a>
          </div>
        </div>
      </div>
    </section>
  );
}
