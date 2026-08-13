import { contact } from "../data/site";
import { stats, networks } from "../data/site";

export function About() {
  return (
    <section id="about" className="px-6 py-20">
      <div className="mx-auto max-w-6xl">
        <SectionLabel number="01" title="About" />
        <blockquote className="font-display mt-8 border-l-2 border-[#C5A059]/50 pl-6 text-2xl italic leading-relaxed text-slate-200 md:text-3xl">
          &ldquo;{contact.tagline}&rdquo;
        </blockquote>
        <p className="mt-8 max-w-4xl text-lg leading-relaxed text-slate-400">{contact.summary}</p>

        <div className="mt-12 grid grid-cols-2 gap-4 md:grid-cols-4">
          {stats.map((stat) => (
            <div
              key={stat.label}
              className="rounded-lg border border-[#C5A059]/25 bg-[#1E293B] p-6 text-center"
            >
              <p className="font-display text-3xl font-bold text-[#F1D592] md:text-4xl">{stat.value}</p>
              <p className="mt-1 text-xs uppercase tracking-[0.25em] text-slate-500">{stat.label}</p>
            </div>
          ))}
        </div>

        <div className="mt-8 overflow-hidden">
          <div className="flex animate-[marquee_30s_linear_infinite] gap-8 whitespace-nowrap text-xs font-semibold uppercase tracking-[0.3em] text-[#C5A059]/70">
            {[...networks, ...networks].map((network, i) => (
              <span key={`${network}-${i}`}>{network} ★</span>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

export function SectionLabel({ number, title }: { number: string; title: string }) {
  return (
    <div className="flex items-center gap-4">
      <span className="text-xs font-medium uppercase tracking-[0.35em] text-[#C5A059]">{number}</span>
      <div className="gold-rule flex-1" />
      <h2 className="font-display text-3xl font-bold text-white md:text-4xl">{title}</h2>
    </div>
  );
}
