const I18N = { en: null, fr: null };

function qs(sel){ return document.querySelector(sel); }
function qsa(sel){ return Array.from(document.querySelectorAll(sel)); }

async function loadJSON(path){
  const r = await fetch(path);
  return await r.json();
}

async function ensureI18n(){
  if(!I18N.en) I18N.en = await loadJSON('i18n/en.json');
  if(!I18N.fr) I18N.fr = await loadJSON('i18n/fr.json');
}

function getLang(){
  return localStorage.getItem('afripulse_lang') || 'en';
}

function setLang(lang){
  localStorage.setItem('afripulse_lang', lang);
}

function applyLangButtons(){
  qsa('[data-lang-btn]').forEach(b=>{
    b.classList.toggle('active', b.dataset.langBtn === getLang());
  });
}

async function translatePage(){
  await ensureI18n();
  const lang = getLang();
  const dict = lang === 'fr' ? I18N.fr : I18N.en;

  qsa('[data-i18n]').forEach(el=>{
    const k = el.dataset.i18n;
    if(dict[k]) el.textContent = dict[k];
  });

  applyLangButtons();
}

async function autoLangByCountry(){
  // If user selected a country, pick FR for francophone list, else browser language heuristic
  const selected = localStorage.getItem('afripulse_country') || '';
  const map = await loadJSON('i18n/country_default_lang.json');
  if(selected){
    const isFR = (map.fr||[]).includes(selected.toUpperCase());
    setLang(isFR ? 'fr' : 'en');
    return;
  }
  const n = (navigator.language||'en').toLowerCase();
  setLang(n.startsWith('fr') ? 'fr' : 'en');
}

function wireLang(){
  qsa('[data-lang-btn]').forEach(b=>{
    b.addEventListener('click', async ()=>{
      setLang(b.dataset.langBtn);
      await translatePage();
    });
  });
}

function wireCountrySelector(){
  const sel = qs('#countrySelect');
  if(!sel) return;
  sel.addEventListener('change', async ()=>{
    localStorage.setItem('afripulse_country', sel.value);
    await autoLangByCountry();
    await translatePage();
  });
  const current = localStorage.getItem('afripulse_country') || '';
  if(current) sel.value = current;
}

window.addEventListener('DOMContentLoaded', async ()=>{
  await autoLangByCountry();
  wireLang();
  wireCountrySelector();
  await translatePage();
});
