import { About } from "./components/About";
import { ExperienceSection } from "./components/ExperienceSection";
import { Footer } from "./components/Footer";
import { Hero } from "./components/Hero";
import { Nav } from "./components/Hero";
import { TvWork } from "./components/TvWork";
import { Writing } from "./components/Writing";

function App() {
  return (
    <div className="min-h-screen bg-[#0F172A] text-slate-200">
      <Nav />
      <main>
        <Hero />
        <About />
        <TvWork />
        <Writing />
        <ExperienceSection />
      </main>
      <Footer />
    </div>
  );
}

export default App;
