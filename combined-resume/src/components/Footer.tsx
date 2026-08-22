import type { ReactNode } from "react";
import { contact, ecosystemLinks } from "../data/site";

export function Footer() {
  return (
    <footer id="contact" className="border-t border-[#C5A059]/20 px-6 py-16">
      <div className="mx-auto max-w-6xl">
        <h2 className="font-display text-3xl font-bold text-white md:text-4xl">
          Let&apos;s Build Something True
        </h2>
        <p className="mt-4 text-slate-400">
          Words create worlds. Desire to inspire.
        </p>

        <div className="mt-10 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
          <ContactItem label="Email">
            <a
              href={`mailto:${contact.email}`}
              className="text-[#F1D592] transition hover:underline"
            >
              {contact.email}
            </a>
          </ContactItem>
          <ContactItem label="Phone">
            <a href={`tel:${contact.phone.replace(/-/g, "")}`} className="text-slate-300 hover:text-[#F1D592]">
              {contact.phone}
            </a>
          </ContactItem>
          <ContactItem label="Location">
            <span className="text-slate-300">{contact.location}</span>
          </ContactItem>
          <ContactItem label="LinkedIn">
            <a
              href={contact.linkedin}
              target="_blank"
              rel="noopener noreferrer"
              className="text-[#F1D592] transition hover:underline"
            >
              Connect ↗
            </a>
          </ContactItem>
        </div>

        <div className="mt-16">
          <h3 className="text-xs font-semibold uppercase tracking-[0.3em] text-[#C5A059]">
            Across the Web
          </h3>
          <div className="mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {ecosystemLinks.map((link) => (
              <a
                key={link.href}
                href={link.href}
                target="_blank"
                rel="noopener noreferrer"
                className="group rounded-lg border border-[#C5A059]/20 bg-[#1E293B] p-4 transition hover:border-[#C5A059]/50"
              >
                <p className="text-sm font-medium text-[#F1D592] group-hover:underline">
                  {link.label} ↗
                </p>
                <p className="mt-1 text-xs text-slate-500">{link.description}</p>
              </a>
            ))}
          </div>
        </div>

        <p className="mt-16 text-center text-xs text-slate-600">
          © {new Date().getFullYear()} Shannon J. Love — All Rights Reserved.
        </p>
      </div>
    </footer>
  );
}

function ContactItem({
  label,
  children,
}: {
  label: string;
  children: ReactNode;
}) {
  return (
    <div>
      <p className="text-[10px] font-semibold uppercase tracking-[0.3em] text-slate-500">
        {label}
      </p>
      <p className="mt-2 text-sm">{children}</p>
    </div>
  );
}
