USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS web.api.mcp.tools.automagic.deploy_customers_html INHERITS web.api.mcp.tools.base.tool :

    METHOD PUBLIC OVERRIDE JsonObject Execute(id AS integer, poArguments AS JsonObject):

DEFINE VARIABLE cPath    AS CHARACTER NO-UNDO.
DEFINE VARIABLE cHtml    AS LONGCHAR  NO-UNDO.
DEFINE VARIABLE oResult  AS Progress.Json.ObjectModel.JsonObject NO-UNDO.

cPath = "C:\progress\OE128_64_WRK\oepas1\webapps\ROOT\customers\index.html".
OS-CREATE-DIR VALUE("C:\progress\OE128_64_WRK\oepas1\webapps\ROOT\customers").

cHtml = "<!DOCTYPE html>~n".
cHtml = cHtml + "<html lang=~"no~">~n".
cHtml = cHtml + "<head><meta charset=~"UTF-8~"><meta name=~"viewport~" content=~"width=device-width,initial-scale=1.0~">~n".
cHtml = cHtml + "<title>Kundevedlikehold - Sports2000</title>~n".
cHtml = cHtml + "<style>~n".
cHtml = cHtml + ":root{--bg:#f0f2f5;--sur:#fff;--pri:#1a56db;--prid:#1240aa;--pril:#e8efff;--dan:#e02424;--suc:#057a55;--bor:#dde2ea;--txt:#1a202c;--mut:#6b7280;--rad:8px;}~n".
cHtml = cHtml + "*{box-sizing:border-box;margin:0;padding:0;}~n".
cHtml = cHtml + "body{font-family:'Segoe UI',system-ui,sans-serif;background:var(--bg);color:var(--txt);font-size:14px;}~n".
cHtml = cHtml + ".topbar{background:var(--pri);color:#fff;height:56px;display:flex;align-items:center;padding:0 24px;gap:12px;box-shadow:0 2px 6px rgba(0,0,0,.2);}~n".
cHtml = cHtml + ".topbar h1{font-size:18px;font-weight:600;flex:1;}.topbar span{font-size:13px;opacity:.8;}~n".
cHtml = cHtml + ".layout{display:flex;height:calc(100vh - 56px);overflow:hidden;}~n".
cHtml = cHtml + ".pl{flex:1;display:flex;flex-direction:column;overflow:hidden;background:var(--sur);border-right:1px solid var(--bor);}~n".
cHtml = cHtml + ".tb{padding:12px 16px;border-bottom:1px solid var(--bor);display:flex;gap:8px;flex-wrap:wrap;align-items:center;background:#fafbfc;}~n".
cHtml = cHtml + ".tb input{height:34px;border:1px solid var(--bor);border-radius:var(--rad);padding:0 10px;font-size:13px;outline:none;}~n".
cHtml = cHtml + ".tb input:focus{border-color:var(--pri);}~n".
cHtml = cHtml + ".tsp{flex:1;}.cnt{font-size:12px;color:var(--mut);white-space:nowrap;}~n".
cHtml = cHtml + ".btn{height:34px;padding:0 14px;border-radius:var(--rad);border:none;cursor:pointer;font-size:13px;font-weight:500;display:inline-flex;align-items:center;gap:6px;transition:background .15s;white-space:nowrap;}~n".
cHtml = cHtml + ".btn:active{transform:scale(.97);}~n".
cHtml = cHtml + ".bp{background:var(--pri);color:#fff;}.bp:hover{background:var(--prid);}~n".
cHtml = cHtml + ".bd{background:var(--dan);color:#fff;}.bd:hover{background:#c81e1e;}~n".
cHtml = cHtml + ".bg{background:transparent;color:var(--mut);border:1px solid var(--bor);}.bg:hover{background:var(--bg);}~n".
cHtml = cHtml + ".bs{height:28px;padding:0 10px;font-size:12px;}.btn:disabled{opacity:.5;cursor:not-allowed;}~n".
cHtml = cHtml + ".tw{flex:1;overflow-y:auto;}~n".
cHtml = cHtml + "table{width:100%;border-collapse:collapse;}~n".
cHtml = cHtml + "thead{position:sticky;top:0;z-index:2;background:#f1f3f6;}~n".
cHtml = cHtml + "th{padding:10px 12px;text-align:left;font-size:12px;font-weight:600;text-transform:uppercase;letter-spacing:.04em;color:var(--mut);border-bottom:1px solid var(--bor);user-select:none;cursor:pointer;white-space:nowrap;}~n".
cHtml = cHtml + "th:hover{color:var(--pri);}th.sa::after{content:' up';color:var(--pri);}th.sd::after{content:' dn';color:var(--pri);}~n".
cHtml = cHtml + "td{padding:9px 12px;border-bottom:1px solid #f0f1f3;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:180px;}~n".
cHtml = cHtml + "tr.dr{cursor:pointer;transition:background .1s;}tr.dr:hover{background:var(--pril);}tr.dr.act{background:#dbeafe;}~n".
cHtml = cHtml + ".tn{text-align:right;font-variant-numeric:tabular-nums;}~n".
cHtml = cHtml + ".badge{display:inline-block;padding:2px 8px;border-radius:12px;font-size:11px;font-weight:600;background:#e0f2fe;color:#0369a1;}~n".
cHtml = cHtml + ".sm{text-align:center;padding:60px 20px;color:var(--mut);}.sm .ic{font-size:36px;margin-bottom:8px;}~n".
cHtml = cHtml + ".spin{display:inline-block;width:20px;height:20px;border:3px solid var(--bor);border-top-color:var(--pri);border-radius:50%;animation:sp .7s linear infinite;}~n".
cHtml = cHtml + "@keyframes sp{to{transform:rotate(360deg);}}~n".
cHtml = cHtml + ".pr{width:420px;display:flex;flex-direction:column;background:var(--sur);overflow:hidden;transition:width .2s;}~n".
cHtml = cHtml + ".pr.cls{width:0;overflow:hidden;}~n".
cHtml = cHtml + ".fh{padding:16px 20px;border-bottom:1px solid var(--bor);display:flex;align-items:center;gap:10px;background:#fafbfc;min-width:380px;}~n".
cHtml = cHtml + ".fh h2{font-size:15px;font-weight:600;flex:1;}~n".
cHtml = cHtml + ".fb{flex:1;overflow-y:auto;padding:16px 20px;min-width:380px;}~n".
cHtml = cHtml + ".ff{padding:12px 20px;border-top:1px solid var(--bor);display:flex;gap:8px;justify-content:flex-end;background:#fafbfc;min-width:380px;}~n".
cHtml = cHtml + ".fg{margin-bottom:14px;}.fg label{display:block;font-size:12px;font-weight:600;color:var(--mut);text-transform:uppercase;letter-spacing:.04em;margin-bottom:4px;}~n".
cHtml = cHtml + ".fg input,.fg textarea{width:100%;border:1px solid var(--bor);border-radius:var(--rad);padding:7px 10px;font-size:13px;font-family:inherit;outline:none;transition:border-color .15s,box-shadow .15s;}~n".
cHtml = cHtml + ".fg input:focus,.fg textarea:focus{border-color:var(--pri);box-shadow:0 0 0 3px rgba(26,86,219,.12);}~n".
cHtml = cHtml + ".fg input[readonly]{background:#f7f8fa;color:var(--mut);cursor:not-allowed;}~n".
cHtml = cHtml + ".fg textarea{resize:vertical;min-height:60px;}~n".
cHtml = cHtml + ".r2{display:grid;grid-template-columns:1fr 1fr;gap:12px;}~n".
cHtml = cHtml + ".st{font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.06em;color:var(--pri);margin:16px 0 10px;padding-bottom:4px;border-bottom:2px solid var(--pril);}~n".
cHtml = cHtml + ".tc{position:fixed;bottom:20px;right:20px;z-index:9999;display:flex;flex-direction:column;gap:8px;}~n".
cHtml = cHtml + ".toast{padding:12px 18px;border-radius:var(--rad);color:#fff;font-size:13px;font-weight:500;box-shadow:0 8px 32px rgba(0,0,0,.14);animation:si .25s ease;display:flex;align-items:center;gap:8px;}~n".
cHtml = cHtml + "@keyframes si{from{transform:translateX(100px);opacity:0;}to{transform:translateX(0);opacity:1;}}~n".
cHtml = cHtml + ".ts{background:var(--suc);}.te{background:var(--dan);}~n".
cHtml = cHtml + ".ov{position:fixed;inset:0;background:rgba(0,0,0,.4);z-index:8000;display:flex;align-items:center;justify-content:center;}~n".
cHtml = cHtml + ".dlg{background:var(--sur);border-radius:12px;padding:28px;max-width:380px;width:90%;box-shadow:0 8px 32px rgba(0,0,0,.14);}~n".
cHtml = cHtml + ".dlg h3{font-size:16px;margin-bottom:10px;}.dlg p{color:var(--mut);font-size:13px;margin-bottom:20px;}~n".
cHtml = cHtml + ".db{display:flex;gap:8px;justify-content:flex-end;}.neg{color:var(--dan);}~n".
cHtml = cHtml + "</style></head><body>~n".
cHtml = cHtml + "<div class=~"topbar~"><h1>&#127970; Kundevedlikehold</h1><span>Sports2000 &middot; PASOE</span></div>~n".
cHtml = cHtml + "<div class=~"layout~">~n".
cHtml = cHtml + "<div class=~"pl~">~n".
cHtml = cHtml + "<div class=~"tb~">~n".
cHtml = cHtml + "<input type=~"text~" id=~"fN~" placeholder=~"Sok navn...~" oninput=~"dbl()~" style=~"width:190px~">~n".
cHtml = cHtml + "<input type=~"text~" id=~"fC~" placeholder=~"Land...~" oninput=~"dbl()~" style=~"width:120px~">~n".
cHtml = cHtml + "<input type=~"text~" id=~"fR~" placeholder=~"SalesRep...~" oninput=~"dbl()~" style=~"width:110px~">~n".
cHtml = cHtml + "<button class=~"btn bg bs~" onclick=~"clr()~">&#x2715; Nullstill</button>~n".
cHtml = cHtml + "<div class=~"tsp~"></div>~n".
cHtml = cHtml + "<span class=~"cnt~" id=~"cnt~"></span>~n".
cHtml = cHtml + "<button class=~"btn bp bs~" onclick=~"nyK()~">+ Ny kunde</button>~n".
cHtml = cHtml + "</div>~n".
cHtml = cHtml + "<div class=~"tw~" id=~"tw~"><div class=~"sm~"><div class=~"spin~"></div><p style=~"margin-top:12px~">Laster...</p></div></div>~n".
cHtml = cHtml + "</div>~n".
cHtml = cHtml + "<div class=~"pr cls~" id=~"prp~">~n".
cHtml = cHtml + "<div class=~"fh~"><div><h2 id=~"ftit~">Kunde</h2><div style=~"font-size:11px;color:var(--mut)~" id=~"fsub~"></div></div>~n".
cHtml = cHtml + "<button class=~"btn bg bs~" onclick=~"closef()~">&#x2715;</button></div>~n".
cHtml = cHtml + "<div class=~"fb~" id=~"fb~"></div>~n".
cHtml = cHtml + "<div class=~"ff~" id=~"ff~"></div>~n".
cHtml = cHtml + "</div></div>~n".
cHtml = cHtml + "<div class=~"tc~" id=~"tc~"></div>~n".
cHtml = cHtml + "<script>~n".
cHtml = cHtml + "const MCP='/web/mcp';~n".
cHtml = cHtml + "let rows=[],actN=null,sCol='CustNum',sAsc=true,dbt=null,mid=1;~n".
cHtml = cHtml + "async function mcp(t,a){~n".
cHtml = cHtml + "  const r=await fetch(MCP,{method:'POST',headers:{'Content-Type':'application/json'},~n".
cHtml = cHtml + "    body:JSON.stringify({jsonrpc:'2.0',id:mid++,method:'tools/call',params:{name:t,arguments:a}})});~n".
cHtml = cHtml + "  const j=await r.json();~n".
cHtml = cHtml + "  if(j.result&&j.result.content&&j.result.content[0]&&j.result.content[0].text)~n".
cHtml = cHtml + "    try{return JSON.parse(j.result.content[0].text);}catch(e){return j.result;}~n".
cHtml = cHtml + "  return j.result||j;~n".
cHtml = cHtml + "}~n".
cHtml = cHtml + "async function load(){~n".
cHtml = cHtml + "  const a={action:'list',maxRows:500};~n".
cHtml = cHtml + "  const n=document.getElementById('fN').value.trim();~n".
cHtml = cHtml + "  const c=document.getElementById('fC').value.trim();~n".
cHtml = cHtml + "  const r2=document.getElementById('fR').value.trim();~n".
cHtml = cHtml + "  if(n)a.name=n; if(c)a.country=c; if(r2)a.salesRep=r2;~n".
cHtml = cHtml + "  document.getElementById('tw').innerHTML='<div class=sm><div class=spin></div></div>';~n".
cHtml = cHtml + "  try{~n".
cHtml = cHtml + "    const d=await mcp('customer_crud',a);~n".
cHtml = cHtml + "    if(!d.customers&&!d.success){serr('Server feil: '+(d.error||JSON.stringify(d)));return;}~n".
cHtml = cHtml + "    rows=d.customers||[];~n".
cHtml = cHtml + "    rnd();~n".
cHtml = cHtml + "    document.getElementById('cnt').textContent=rows.length+' kunder';~n".
cHtml = cHtml + "  }catch(e){document.getElementById('tw').innerHTML='<div class=sm><p>'+e.message+'</p></div>';}~n".
cHtml = cHtml + "}~n".
cHtml = cHtml + "function dbl(){clearTimeout(dbt);dbt=setTimeout(load,350);}~n".
cHtml = cHtml + "function clr(){document.getElementById('fN').value='';document.getElementById('fC').value='';document.getElementById('fR').value='';load();}~n".
cHtml = cHtml + "const COLS=[{k:'CustNum',l:'#',c:'tn'},{k:'Name',l:'Navn',c:''},{k:'City',l:'By',c:''},{k:'Country',l:'Land',c:''},{k:'Phone',l:'Telefon',c:''},{k:'SalesRep',l:'Rep',c:''},{k:'CreditLimit',l:'Kreditt',c:'tn'},{k:'Balance',l:'Saldo',c:'tn'},{k:'Discount',l:'Rab%',c:'tn'}];~n".
cHtml = cHtml + "function srt(){return[...rows].sort((a,b)=>{let av=a[sCol],bv=b[sCol];if(typeof av==='string')av=av.toLowerCase();if(typeof bv==='string')bv=bv.toLowerCase();if(av<bv)return sAsc?-1:1;if(av>bv)return sAsc?1:-1;return 0;});}~n".
cHtml = cHtml + "function rnd(){~n".
cHtml = cHtml + "  const rs=srt();~n".
cHtml = cHtml + "  if(!rs.length){document.getElementById('tw').innerHTML='<div class=sm><p>Ingen kunder</p></div>';return;}~n".
cHtml = cHtml + "  const fmt=new Intl.NumberFormat('no-NO',{minimumFractionDigits:2});~n".
cHtml = cHtml + "  const th=COLS.map(c2=>{let cl='';if(c2.k===sCol)cl=sAsc?'sa':'sd';return'<th class='+cl+' onclick='+String.fromCharCode(34)+'ss('+String.fromCharCode(39)+c2.k+String.fromCharCode(39)+')'+String.fromCharCode(34)+'>'+c2.l+'</th>';}).join('');~n".
cHtml = cHtml + "  const tb=rs.map(r=>{~n".
cHtml = cHtml + "    const ac=r.CustNum===actN;~n".
cHtml = cHtml + "    const cs=COLS.map(c2=>{~n".
cHtml = cHtml + "      let v=r[c2.k]!=null?r[c2.k]:'';~n".
cHtml = cHtml + "      if(c2.k==='CreditLimit'||c2.k==='Balance'){v='<span class='+(c2.k==='Balance'&&v<0?'neg':'')+'>'+fmt.format(v)+'</span>';}~n".
cHtml = cHtml + "      else if(c2.k==='Discount'){v=v?v+'%':'';}~n".
cHtml = cHtml + "      else if(c2.k==='SalesRep'&&v){v='<span class=badge>'+v+'</span>';}~n".
cHtml = cHtml + "      return'<td class='+c2.c+'>'+v+'</td>';~n".
cHtml = cHtml + "    }).join('');~n".
cHtml = cHtml + "    return'<tr class=dr'+(ac?' act':'')+' onclick='+String.fromCharCode(34)+'sel('+r.CustNum+')'+String.fromCharCode(34)+'>'+cs+'</tr>';~n".
cHtml = cHtml + "  }).join('');~n".
cHtml = cHtml + "  document.getElementById('tw').innerHTML='<table><thead><tr>'+th+'</tr></thead><tbody>'+tb+'</tbody></table>';~n".
cHtml = cHtml + "}~n".
cHtml = cHtml + "function ss(c){if(sCol===c)sAsc=!sAsc;else{sCol=c;sAsc=true;}rnd();}~n".
cHtml = cHtml + "async function sel(n){~n".
cHtml = cHtml + "  actN=n;rnd();~n".
cHtml = cHtml + "  document.getElementById('ftit').textContent='Rediger kunde';~n".
cHtml = cHtml + "  document.getElementById('fsub').textContent='CustNum: '+n;~n".
cHtml = cHtml + "  showp();~n".
cHtml = cHtml + "  document.getElementById('fb').innerHTML='<div class=sm><div class=spin></div></div>';~n".
cHtml = cHtml + "  document.getElementById('ff').innerHTML='';~n".
cHtml = cHtml + "  try{const d=await mcp('customer_crud',{action:'get',custNum:n});~n".
cHtml = cHtml + "    if(!d.success){serr(d.error||'Ikke funnet');return;}rf(d,false);~n".
cHtml = cHtml + "  }catch(e){serr(e.message);}~n".
cHtml = cHtml + "}~n".
cHtml = cHtml + "function nyK(){actN=null;rnd();document.getElementById('ftit').textContent='Ny kunde';document.getElementById('fsub').textContent='Fyll inn og lagre';showp();rf({},true);}~n".
cHtml = cHtml + "function fi(id,lbl,val,ro,tp){return'<div class=fg><label>'+lbl+'</label><input type='+(tp||'text')+' id=f_'+id+' value='+String.fromCharCode(34)+esc(val)+String.fromCharCode(34)+(ro?' readonly':'')+'/></div>';}~n".
cHtml = cHtml + "function fa(id,lbl,val){return'<div class=fg><label>'+lbl+'</label><textarea id=f_'+id+'>'+esc(val)+'</textarea></div>';}~n".
cHtml = cHtml + "function esc(v){return String(v==null?'':v).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/\x22/g,'&#34;');}~n".
cHtml = cHtml + "function rf(d,isN){~n".
cHtml = cHtml + "  let h='<div class=st>Hovudinfo</div>'+fi('CustNum','Kundenummer',d.CustNum||'',true)+fi('Name','Navn *',d.Name||'')+fi('Contact','Kontaktperson',d.Contact||'')+fi('EmailAddress','E-post',d.EmailAddress||'',false,'email')+fi('Phone','Telefon',d.Phone||'')+fi('Fax','Faks',d.Fax||'');~n".
cHtml = cHtml + "  h+='<div class=st>Adresse</div>'+fi('Address','Gateadresse',d.Address||'')+fi('Address2','Adresse 2',d.Address2||'');~n".
cHtml = cHtml + "  h+='<div class=r2>'+fi('PostalCode','Postnummer',d.PostalCode||'')+fi('City','By',d.City||'')+'</div>';~n".
cHtml = cHtml + "  h+='<div class=r2>'+fi('State','Stat/region',d.State||'')+fi('Country','Land',d.Country||'')+'</div>';~n".
cHtml = cHtml + "  h+='<div class=st>Handel</div><div class=r2>'+fi('SalesRep','Selger (kode)',d.SalesRep||'')+fi('Terms','Bet.betingelser',d.Terms||'')+'</div>';~n".
cHtml = cHtml + "  h+='<div class=r2>'+fi('CreditLimit','Kredittgrense',d.CreditLimit||0,false,'number')+fi('Discount','Rabatt %',d.Discount||0,false,'number')+'</div>';~n".
cHtml = cHtml + "  if(!isN)h+='<div class=fg><label>Saldo</label><input type=text value='+String.fromCharCode(34)+esc(d.Balance||0)+String.fromCharCode(34)+' readonly/></div>';~n".
cHtml = cHtml + "  h+='<div class=st>Kommentarer</div>'+fa('Comments','Kommentarer',d.Comments||'');~n".
cHtml = cHtml + "  document.getElementById('fb').innerHTML=h;~n".
cHtml = cHtml + "  if(isN){document.getElementById('f_CustNum').closest('.fg').style.display='none';}~n".
cHtml = cHtml + "  else{document.getElementById('f_CustNum').readOnly=true;}~n".
cHtml = cHtml + "  const ff=document.getElementById('ff');~n".
cHtml = cHtml + "  if(isN)ff.innerHTML='<button class='+String.fromCharCode(34)+'btn bg'+String.fromCharCode(34)+' onclick=closef()>Avbryt</button><button class='+String.fromCharCode(34)+'btn bp'+String.fromCharCode(34)+' onclick=sN()>Lagre ny</button>';~n".
cHtml = cHtml + "  else ff.innerHTML='<button class='+String.fromCharCode(34)+'btn bg'+String.fromCharCode(34)+' style='+String.fromCharCode(34)+'margin-right:auto;border-color:var(--dan);color:var(--dan)'+String.fromCharCode(34)+' onclick='+String.fromCharCode(34)+'cD('+d.CustNum+')'+String.fromCharCode(34)+'>Slett</button><button class='+String.fromCharCode(34)+'btn bg'+String.fromCharCode(34)+' onclick=closef()>Avbryt</button><button class='+String.fromCharCode(34)+'btn bp'+String.fromCharCode(34)+' onclick='+String.fromCharCode(34)+'sE('+d.CustNum+')'+String.fromCharCode(34)+'>Lagre</button>';~n".
cHtml = cHtml + "}~n".
cHtml = cHtml + "function rfc(){~n".
cHtml = cHtml + "  const a={};const g=id=>(document.getElementById('f_'+id)||{}).value||'';~n".
cHtml = cHtml + "  if(g('Name'))a.name=g('Name');if(g('Contact'))a.contact=g('Contact');~n".
cHtml = cHtml + "  if(g('EmailAddress'))a.emailAddress=g('EmailAddress');~n".
cHtml = cHtml + "  if(g('Phone'))a.phone=g('Phone');if(g('Fax'))a.fax=g('Fax');~n".
cHtml = cHtml + "  if(g('Address'))a.address=g('Address');if(g('Address2'))a.address2=g('Address2');~n".
cHtml = cHtml + "  if(g('PostalCode'))a.postalCode=g('PostalCode');if(g('City'))a.city=g('City');~n".
cHtml = cHtml + "  if(g('State'))a.state=g('State');if(g('Country'))a.country=g('Country');~n".
cHtml = cHtml + "  if(g('SalesRep'))a.salesRep=g('SalesRep');if(g('Terms'))a.terms=g('Terms');~n".
cHtml = cHtml + "  if(g('Comments'))a.comments=g('Comments');~n".
cHtml = cHtml + "  const cl=(document.getElementById('f_CreditLimit')||{}).value;~n".
cHtml = cHtml + "  const dc=(document.getElementById('f_Discount')||{}).value;~n".
cHtml = cHtml + "  if(cl!=null&&cl!='')a.creditLimit=parseFloat(cl)||0;~n".
cHtml = cHtml + "  if(dc!=null&&dc!='')a.discount=parseInt(dc)||0;~n".
cHtml = cHtml + "  return a;~n".
cHtml = cHtml + "}~n".
cHtml = cHtml + "async function sN(){~n".
cHtml = cHtml + "  const a=rfc();if(!a.name){serr('Navn er pakrevd');return;}~n".
cHtml = cHtml + "  a.action='create';fl(true);~n".
cHtml = cHtml + "  try{const d=await mcp('customer_crud',a);~n".
cHtml = cHtml + "    if(d.success){sok('Kunde opprettet: '+d.Name+' (#'+d.CustNum+')');actN=d.CustNum;closef();await load();sel(d.CustNum);}~n".
cHtml = cHtml + "    else serr(d.error||'Feil ved opprettelse');~n".
cHtml = cHtml + "  }catch(e){serr(e.message);}fl(false);~n".
cHtml = cHtml + "}~n".
cHtml = cHtml + "async function sE(n){~n".
cHtml = cHtml + "  const a=rfc();a.action='update';a.custNum=n;fl(true);~n".
cHtml = cHtml + "  try{const d=await mcp('customer_crud',a);~n".
cHtml = cHtml + "    if(d.success){sok('Lagret: '+d.Name);await load();sel(n);}~n".
cHtml = cHtml + "    else serr(d.error||'Feil ved lagring');~n".
cHtml = cHtml + "  }catch(e){serr(e.message);}fl(false);~n".
cHtml = cHtml + "}~n".
cHtml = cHtml + "function cD(n){~n".
cHtml = cHtml + "  const nm=document.getElementById('f_Name').value||'Kunde '+n;~n".
cHtml = cHtml + "  const o=document.createElement('div');o.className='ov';~n".
cHtml = cHtml + "  o.innerHTML='<div class=dlg><h3>Slett kunde?</h3><p>Vil du slette <strong>'+esc(nm)+'</strong> (#'+n+')?<br>Kan ikke angres.</p><div class=db><button class='+String.fromCharCode(34)+'btn bg'+String.fromCharCode(34)+' onclick=this.closest('.ov').remove()>Avbryt</button><button class='+String.fromCharCode(34)+'btn bd'+String.fromCharCode(34)+' onclick='+String.fromCharCode(34)+'dD('+n+');this.closest('.ov').remove()'+String.fromCharCode(34)+'>Slett</button></div></div>';~n".
cHtml = cHtml + "  document.body.appendChild(o);~n".
cHtml = cHtml + "}~n".
cHtml = cHtml + "async function dD(n){~n".
cHtml = cHtml + "  try{const d=await mcp('customer_crud',{action:'delete',custNum:n});~n".
cHtml = cHtml + "    if(d.success){sok(d.message);closef();await load();}else serr(d.error||'Feil');~n".
cHtml = cHtml + "  }catch(e){serr(e.message);}~n".
cHtml = cHtml + "}~n".
cHtml = cHtml + "function showp(){document.getElementById('prp').classList.remove('cls');}~n".
cHtml = cHtml + "function closef(){document.getElementById('prp').classList.add('cls');actN=null;rnd();}~n".
cHtml = cHtml + "function fl(on){document.querySelectorAll('#ff .btn').forEach(b=>b.disabled=on);}~n".
cHtml = cHtml + "function toast(m,tp){const e=document.createElement('div');e.className='toast '+(tp==='s'?'ts':'te');e.textContent=(tp==='s'?'OK: ':'Feil: ')+m;document.getElementById('tc').appendChild(e);setTimeout(()=>e.remove(),3500);}~n".
cHtml = cHtml + "function sok(m){toast(m,'s');}function serr(m){toast(m,'e');}~n".
cHtml = cHtml + "load();~n".
cHtml = cHtml + "</script></body></html>~n".

COPY-LOB FROM cHtml TO FILE cPath NO-CONVERT.

oResult = NEW Progress.Json.ObjectModel.JsonObject().
IF OS-ERROR = 0 THEN DO:
    oResult:Add("status",  "ok").
    oResult:Add("message", "HTML deployed").
    oResult:Add("path",    cPath).
    oResult:Add("url",     "/customers/index.html").
END.
ELSE DO:
    oResult:Add("status",  "error").
    oResult:Add("message", "OS-ERROR=" + STRING(OS-ERROR)).
END.
RETURN CreateMcpResponseJson(id, oResult, false).


    END.

END CLASS.
