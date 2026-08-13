import { awards, education, experience, expertise } from "../data/experience";
import { SectionLabel } from "./About";

export function ExperienceSection() {
  return (
    <section id="experience" className="border-t border-[#C5A059]/15 bg-[#0B1220] px-6 py-20 print-break">
      <div className="mx-auto max-w-6xl">
        <SectionLabel number="04" title="Experience" />

        <div className="mt-12 space-y-10">
          {experience.map((role) => (
            <article
              key={`${role.title}-${role.period}`}
              className="border-l-2 border-[#C5A059]/30 pl-6"
            >
              <div className="flex flex-wrap items-baseline justify-between gap-2">
                <h3 className="font-display text-xl font-bold text-white md:text-2xl">
                  {role.title}
                </h3>
                <span className="text-xs uppercase tracking-[0.2em] text-[#C5A059]">
                  {role.period}
                </span>
              </div>
              <p className="mt-1 text-sm text-slate-400">
                {role.companyUrl ? (
                  <a
                    href={role.companyUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="transition hover:text-[#F1D592]"
                  >
                    {role.company} ↗
                  </a>
                ) : (
                  role.company
                )}{" "}
                · {role.location}
              </p>
              <ul className="mt-4 space-y-2">
                {role.bullets.map((bullet) => (
                  <li key={bullet} className="flex gap-2 text-sm leading-relaxed text-slate-400">
                    <span className="mt-1.5 h-1 w-1 shrink-0 rounded-full bg-[#C5A059]" />
                    {bullet}
                  </li>
                ))}
              </ul>
            </article>
          ))}
        </div>

        <div className="mt-16">
          <h3 className="text-xs font-semibold uppercase tracking-[0.3em] text-[#C5A059]">
            Expertise
          </h3>
          <div className="mt-4 flex flex-wrap gap-2">
            {expertise.map((skill) => (
              <span
                key={skill}
                className="rounded-full border border-[#C5A059]/25 px-3 py-1 text-xs text-slate-300"
              >
                {skill}
              </span>
            ))}
          </div>
        </div>

        <div className="mt-16 grid gap-8 md:grid-cols-2">
          <div>
            <h3 className="text-xs font-semibold uppercase tracking-[0.3em] text-[#C5A059]">
              Awards & Honors
            </h3>
            <ul className="mt-4 space-y-4">
              {awards.map((award) => (
                <li key={award.title}>
                  <p className="font-medium text-slate-200">{award.title}</p>
                  <p className="mt-1 text-sm text-slate-500">{award.detail}</p>
                </li>
              ))}
            </ul>
          </div>
          <div>
            <h3 className="text-xs font-semibold uppercase tracking-[0.3em] text-[#C5A059]">
              Education
            </h3>
            <div className="mt-4 text-slate-300">
              <p className="font-display text-lg font-bold">{education.school}</p>
              <p className="mt-1 text-sm text-slate-400">
                {education.degree} · {education.honors} · {education.year}
              </p>
              <p className="mt-3 text-sm text-slate-500">{education.certification}</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
