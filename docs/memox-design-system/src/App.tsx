/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { 
  Search, 
  Settings, 
  BookOpen, 
  BrainCircuit, 
  ArrowRight, 
  Flame, 
  Layers, 
  GraduationCap, 
  BarChart3 
} from 'lucide-react';
import { motion } from 'motion/react';

export default function App() {
  return (
    <div className="min-h-screen pb-24 md:pb-12">
      {/* Top Navigation */}
      <header className="fixed top-0 w-full z-50 bg-surface/80 backdrop-blur-xl px-6 py-4 flex justify-between items-center max-w-7xl mx-auto left-0 right-0">
        <div className="flex items-center gap-3">
          <BookOpen className="text-primary w-6 h-6" />
          <span className="text-xl font-bold text-primary tracking-tight font-headline">MemoX</span>
        </div>
        <div className="flex items-center gap-4">
          <button className="p-2 hover:bg-surface-container-low rounded-xl transition-colors">
            <Search className="w-5 h-5 text-on-surface-variant" />
          </button>
          <button className="p-2 hover:bg-surface-container-low rounded-xl transition-colors">
            <Settings className="w-5 h-5 text-on-surface-variant" />
          </button>
        </div>
      </header>

      <main className="pt-24 px-6 md:px-12 max-w-7xl mx-auto space-y-20">
        {/* Hero Section */}
        <section className="space-y-4">
          <div className="space-y-1">
            <span className="text-[10px] font-bold tracking-[0.2em] text-primary uppercase">
              The Cognitive Architect
            </span>
            <h1 className="text-4xl md:text-5xl font-extrabold tracking-tight text-on-surface">
              Theme Foundation Board
            </h1>
          </div>
          <p className="text-on-surface-variant max-w-2xl leading-relaxed">
            Systematic visual tokens for high-performance learning. Documentation of the MemoX Design Language across color, typography, and architectural components.
          </p>
        </section>

        {/* Color System Section */}
        <section className="space-y-8">
          <div className="flex items-center gap-3">
            <div className="w-1 h-8 bg-primary rounded-full" />
            <h2 className="text-2xl font-bold">Color System & M3 Roles</h2>
          </div>
          
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
            <ColorSwatch hex="#24389C" label="Primary" sub="BRAND / ACTION" bg="bg-primary" />
            <ColorSwatch hex="#4858AB" label="Secondary" sub="NAVIGATION / TONAL" bg="bg-secondary" />
            <ColorSwatch hex="#004E1A" label="Mastery" sub="GROWTH / SUCCESS" bg="bg-tertiary" />
            <ColorSwatch hex="#BA1A1A" label="Due State" sub="TENSION / ALERT" bg="bg-error" />
            <ColorSwatch hex="#F97316" label="Streak" sub="MOMENTUM" bg="bg-streak" />
            <ColorSwatch hex="#757684" label="Outline" sub="STRUCTURE" bg="bg-outline" />
          </div>

          <div className="bg-surface-container-low p-8 rounded-2xl space-y-6">
            <h3 className="text-[10px] font-bold text-on-surface-variant uppercase tracking-widest">
              Surface Architecture (Levels 1-5)
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-5 gap-6">
              <SurfaceLevel hex="#F7F9FB" label="Surface Bright" bg="bg-surface-bright" />
              <SurfaceLevel hex="#F2F4F6" label="Container Low" bg="bg-surface-container-low" />
              <SurfaceLevel hex="#ECEEF0" label="Container Mid" bg="bg-surface-container" />
              <SurfaceLevel hex="#E6E8EA" label="Container High" bg="bg-surface-container-high" />
              <SurfaceLevel hex="#E0E3E5" label="Container Highest" bg="bg-surface-container-highest" />
            </div>
          </div>
        </section>

        {/* Typography Ladder Section */}
        <section className="space-y-8">
          <div className="flex items-center gap-3">
            <div className="w-1 h-8 bg-primary rounded-full" />
            <h2 className="text-2xl font-bold">Typography Ladder</h2>
          </div>
          
          <div className="bg-surface-container-lowest p-8 md:p-12 rounded-3xl ghost-border shadow-sm space-y-12">
            <TypeRow 
              sample="Hero Metric" 
              specs="48px / Bold / -2% Tracking" 
              role="DISPLAY LARGE" 
              className="text-[48px] font-extrabold tracking-tighter text-primary leading-none"
            />
            <TypeRow 
              sample="Screen Title Anchor" 
              specs="32px / Bold" 
              role="HEADLINE LARGE" 
              className="text-[32px] font-bold tracking-tight text-on-surface"
            />
            <TypeRow 
              sample="Section Title Marker" 
              specs="24px / Semibold" 
              role="HEADLINE SMALL" 
              className="text-[24px] font-semibold text-on-surface"
            />
            <TypeRow 
              sample="Card Title & Primary Interaction" 
              specs="20px / Medium" 
              role="TITLE MEDIUM" 
              className="text-[20px] font-medium text-on-surface"
            />
            <TypeRow 
              sample="The body text is designed for long-form study sessions, prioritizing readability and white space." 
              specs="16px / Regular / 1.5x Leading" 
              role="BODY LARGE" 
              className="text-[16px] text-on-surface-variant max-w-md leading-[1.5]"
            />
            <TypeRow 
              sample="Supporting instructional text or hints" 
              specs="14px / Italic" 
              role="BODY MEDIUM" 
              className="text-[14px] text-on-surface-variant italic"
            />
            <TypeRow 
              sample="METADATA LABEL" 
              specs="12px / Bold / +5% Tracking" 
              role="LABEL SMALL" 
              className="text-[12px] font-bold uppercase tracking-[0.1em] text-on-surface-variant"
            />
          </div>
        </section>

        {/* Token Summary Section */}
        <section className="space-y-8">
          <div className="flex items-center gap-3">
            <div className="w-1 h-8 bg-primary rounded-full" />
            <h2 className="text-2xl font-bold">Token Summary</h2>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            <TokenGroup title="SPACING (4PX GRID)">
              <div className="bg-surface-container-low p-4 rounded-xl space-y-2">
                <TokenItem label="Compact" value="4px / 8px" />
                <TokenItem label="Base" value="16px / 24px" />
                <TokenItem label="Wide" value="32px / 48px" />
              </div>
            </TokenGroup>

            <TokenGroup title="RADIUS (PRECISE)">
              <div className="grid grid-cols-2 gap-2">
                <div className="h-12 border border-outline-variant/30 rounded-[4px] flex items-center justify-center text-[10px] font-bold">4px</div>
                <div className="h-12 border border-outline-variant/30 rounded-[8px] flex items-center justify-center text-[10px] font-bold">8px</div>
                <div className="h-12 border border-outline-variant/30 rounded-[12px] flex items-center justify-center text-[10px] font-bold">12px</div>
                <div className="h-12 border border-outline-variant/30 rounded-full flex items-center justify-center text-[10px] font-bold">Full</div>
              </div>
            </TokenGroup>

            <TokenGroup title="ELEVATION">
              <div className="space-y-2">
                <div className="p-3 bg-surface ghost-border rounded-lg text-[10px] font-bold">Level 0: Flat</div>
                <div className="p-3 bg-white shadow-[0px_4px_12px_rgba(25,28,30,0.04)] rounded-lg text-[10px] font-bold">Level 1: Soft</div>
                <div className="p-3 bg-white shadow-[0px_12px_32px_rgba(25,28,30,0.06)] rounded-lg text-[10px] font-bold">Level 2: Focus</div>
              </div>
            </TokenGroup>

            <TokenGroup title="BORDER SYSTEM">
              <div className="bg-surface-container-low p-4 rounded-xl space-y-3">
                <div className="h-[1px] bg-outline-variant/30 w-full" />
                <span className="text-[10px] block text-on-surface-variant">Ghost Border: 1px 15% Outline</span>
                <div className="flex items-center gap-2">
                  <div className="w-2 h-8 bg-primary rounded-full" />
                  <span className="text-[10px] text-on-surface-variant">Focus Marker: 4px Solid Accent</span>
                </div>
              </div>
            </TokenGroup>
          </div>
        </section>

        {/* Component Samples Section */}
        <section className="space-y-8 pb-12">
          <div className="flex items-center gap-3">
            <div className="w-1 h-8 bg-primary rounded-full" />
            <h2 className="text-2xl font-bold">Component Visual Samples</h2>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {/* Deck Card */}
            <motion.div 
              whileHover={{ y: -4 }}
              className="bg-surface-container-lowest p-6 rounded-2xl ghost-border flex flex-col gap-6 group transition-all"
            >
              <div className="flex justify-between items-start">
                <div className="p-3 bg-primary/5 text-primary rounded-xl">
                  <BrainCircuit className="w-6 h-6" />
                </div>
                <span className="text-[10px] font-bold bg-mastery-fixed text-on-mastery-fixed px-2 py-1 rounded-full uppercase tracking-wider">
                  Mastered
                </span>
              </div>
              <div className="space-y-2">
                <h4 className="text-xl font-bold">Advanced Neuroplasticity</h4>
                <p className="text-sm text-on-surface-variant leading-relaxed">
                  Fundamental concepts of synaptic strengthening and prune mechanisms in cortical regions.
                </p>
              </div>
              <div className="space-y-3">
                <div className="flex justify-between items-center text-[10px] font-bold uppercase tracking-widest">
                  <span>Mastery Progress</span>
                  <span>82%</span>
                </div>
                <div className="h-2 w-full bg-mastery-fixed rounded-full overflow-hidden">
                  <div className="h-full bg-mastery w-[82%] rounded-full" />
                </div>
              </div>
            </motion.div>

            {/* Interaction Elements */}
            <div className="flex flex-col gap-8">
              <div className="space-y-2">
                <label className="text-[10px] font-bold uppercase tracking-widest text-primary ml-1">Search Deck</label>
                <div className="relative group">
                  <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-outline group-focus-within:text-primary transition-colors" />
                  <input 
                    type="text" 
                    placeholder="Enter keywords..." 
                    className="w-full pl-12 pr-4 py-3 bg-surface-container-low border-none rounded-xl focus:ring-0 focus:bg-surface-container-lowest transition-all"
                  />
                  <div className="absolute bottom-0 left-0 h-0.5 bg-primary w-0 group-focus-within:w-full transition-all duration-300" />
                </div>
              </div>
              <div className="flex flex-col gap-3">
                <button className="bg-primary text-white py-4 px-6 rounded-xl font-bold flex items-center justify-center gap-2 hover:opacity-90 transition-opacity">
                  Primary Study Action
                  <ArrowRight className="w-4 h-4" />
                </button>
                <button className="bg-surface-container-high text-primary py-4 px-6 rounded-xl font-bold flex items-center justify-center gap-2 hover:bg-surface-container-highest transition-colors">
                  Secondary Review
                </button>
              </div>
            </div>

            {/* Chips & Streak */}
            <div className="bg-surface-container-low p-8 rounded-2xl flex flex-col justify-between gap-8">
              <div className="space-y-6">
                <span className="text-[10px] font-bold uppercase tracking-widest text-on-surface-variant">Active Mastery Chips</span>
                <div className="flex flex-wrap gap-2">
                  <Chip color="bg-mastery" label="Synapses" />
                  <Chip color="bg-primary" label="Memory" />
                  <Chip color="bg-streak" label="Recall" />
                </div>
              </div>
              <div className="p-4 bg-primary/5 rounded-xl flex items-center gap-4">
                <div className="text-streak">
                  <Flame className="w-6 h-6 fill-streak" />
                </div>
                <div>
                  <span className="text-[10px] font-bold text-primary uppercase tracking-widest block">Daily Streak</span>
                  <span className="text-lg font-extrabold text-primary">14 Days Strong</span>
                </div>
              </div>
            </div>
          </div>
        </section>
      </main>

      {/* Bottom Navigation (Mobile) */}
      <nav className="fixed bottom-0 left-0 w-full z-50 flex justify-around items-center px-4 py-3 bg-surface/80 backdrop-blur-xl md:hidden ghost-border border-x-0 border-b-0">
        <NavItem icon={<Layers />} label="Decks" />
        <NavItem icon={<GraduationCap />} label="Study" />
        <NavItem icon={<BarChart3 />} label="Stats" />
        <NavItem icon={<Settings />} label="Settings" active />
      </nav>
    </div>
  );
}

function ColorSwatch({ hex, label, sub, bg }: { hex: string, label: string, sub: string, bg: string }) {
  return (
    <div className="flex flex-col gap-2">
      <div className={`h-24 w-full ${bg} rounded-xl flex items-end p-3`}>
        <span className="text-white text-[10px] font-bold">{hex}</span>
      </div>
      <span className="font-bold text-sm">{label}</span>
      <span className="text-[10px] text-on-surface-variant uppercase tracking-wider">{sub}</span>
    </div>
  );
}

function SurfaceLevel({ hex, label, bg }: { hex: string, label: string, bg: string }) {
  return (
    <div className="flex flex-col gap-3">
      <div className={`h-16 w-full ${bg} rounded-xl ghost-border`} />
      <span className="text-xs font-bold">{label}</span>
      <span className="text-[10px] text-on-surface-variant">{hex}</span>
    </div>
  );
}

function TypeRow({ sample, specs, role, className }: { sample: string, specs: string, role: string, className: string }) {
  return (
    <div className="flex flex-col md:flex-row md:items-baseline justify-between border-b border-outline-variant/20 pb-6 gap-4 last:border-0 last:pb-0">
      <span className={className}>{sample}</span>
      <div className="text-right shrink-0">
        <span className="text-xs font-bold text-primary block">{specs}</span>
        <span className="text-[10px] text-on-surface-variant uppercase tracking-widest">{role}</span>
      </div>
    </div>
  );
}

function TokenGroup({ title, children }: { title: string, children: React.ReactNode }) {
  return (
    <div className="space-y-4">
      <span className="text-[10px] font-bold uppercase tracking-widest text-primary">{title}</span>
      {children}
    </div>
  );
}

function TokenItem({ label, value }: { label: string, value: string }) {
  return (
    <div className="flex justify-between items-center">
      <span className="text-xs">{label}</span>
      <span className="text-xs font-mono font-bold">{value}</span>
    </div>
  );
}

function Chip({ color, label }: { color: string, label: string }) {
  return (
    <div className="flex items-center gap-2 bg-white ghost-border px-3 py-1.5 rounded-full">
      <div className={`w-2 h-2 ${color} rounded-full`} />
      <span className="text-xs font-bold">{label}</span>
    </div>
  );
}

function NavItem({ icon, label, active = false }: { icon: React.ReactNode, label: string, active?: boolean }) {
  return (
    <div className={`flex flex-col items-center justify-center px-4 py-2 rounded-2xl transition-all ${active ? 'bg-primary/5 text-primary' : 'text-on-surface-variant'}`}>
      <div className="w-6 h-6">{icon}</div>
      <span className="text-[10px] font-bold uppercase tracking-widest mt-1">{label}</span>
    </div>
  );
}
