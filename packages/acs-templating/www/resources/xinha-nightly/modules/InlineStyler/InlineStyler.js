/* This compressed file is part of Xinha. For uncomressed sources, forum, and bug reports, go to xinha.org */
Xinha.InlineStyler=function(b,c,a,d){this.element=b;this.editor=c;this.dialog=a;this.doc=d?d:document;this.inputs={styles:{},aux:{}};this.styles={};this.auxData={}};Xinha.InlineStyler.getLength=function(b){var a=parseInt(b);if(isNaN(a)){a=""}return a};Xinha.InlineStyler.prototype.applyStyle=function(f){var b=this.element;var d=b.style;for(var a in f){if(typeof f[a]=="function"){continue}if(f[a]!=null){var e=f[a].value||f[a]}switch(a){case"backgroundImage":if(/\S/.test(e)){d.backgroundImage="url("+e+")"}else{d.backgroundImage="none"}break;case"borderCollapse":d.borderCollapse=f[a]=="on"?"collapse":"separate";break;case"width":if(/\S/.test(e)){d.width=e+this.inputs.aux.widthUnit.value}else{d.width=""}break;case"height":if(/\S/.test(e)){d.height=e+this.inputs.aux.heightUnit.value}else{d.height=""}break;case"textAlign":if(e=="char"){var c=this.inputs.aux.textAlignChar.value;if(c=='"'){c='\\"'}d.textAlign='"'+c+'"'}else{if(e=="-"){d.textAlign=""}else{d.textAlign=e}}break;case"verticalAlign":b.vAlign="";if(e=="-"){d.verticalAlign=""}else{d.verticalAlign=e}break;case"float":if(Xinha.is_ie){d.styleFloat=e}else{d.cssFloat=e}break;case"borderWidth":d[a]=e+"px";break;default:d[a]=e;break}}};Xinha.InlineStyler.prototype.createStyleLayoutFieldset=function(){var m=this;var f=this.editor;var u=this.doc;var d=this.element;var l=u.createElement("fieldset");var c=u.createElement("legend");l.appendChild(c);c.innerHTML=Xinha._lc("Layout","TableOperations");var q=u.createElement("table");l.appendChild(q);q.style.width="100%";var a=u.createElement("tbody");q.appendChild(a);var r=d.tagName.toLowerCase();var b,h,j,n,k,e,o;if(r!="td"&&r!="tr"&&r!="th"){b=u.createElement("tr");a.appendChild(b);h=u.createElement("td");h.className="label";b.appendChild(h);h.innerHTML=Xinha._lc("Float","TableOperations")+":";h=u.createElement("td");b.appendChild(h);n=u.createElement("select");n.name=this.dialog.createId("float");h.appendChild(n);this.inputs.styles["float"]=n;e=["None","Left","Right"];for(var o=0;o<e.length;++o){var g=e[o];var t=e[o].toLowerCase();k=u.createElement("option");k.innerHTML=Xinha._lc(g,"TableOperations");k.value=t;if(Xinha.is_ie){k.selected=((""+d.style.styleFloat).toLowerCase()==t)}else{k.selected=((""+d.style.cssFloat).toLowerCase()==t)}n.appendChild(k)}}b=u.createElement("tr");a.appendChild(b);h=u.createElement("td");h.className="label";b.appendChild(h);h.innerHTML=Xinha._lc("Width","TableOperations")+":";h=u.createElement("td");b.appendChild(h);j=u.createElement("input");j.name=this.dialog.createId("width");j.type="text";j.value=Xinha.InlineStyler.getLength(d.style.width);j.size="5";this.inputs.styles.width=j;j.style.marginRight="0.5em";h.appendChild(j);n=u.createElement("select");n.name=this.dialog.createId("widthUnit");this.inputs.aux.widthUnit=n;k=u.createElement("option");k.innerHTML=Xinha._lc("percent","TableOperations");k.value="%";k.selected=/%/.test(d.style.width);n.appendChild(k);k=u.createElement("option");k.innerHTML=Xinha._lc("pixels","TableOperations");k.value="px";k.selected=/px/.test(d.style.width);n.appendChild(k);h.appendChild(n);n.style.marginRight="0.5em";h.appendChild(u.createTextNode(Xinha._lc("Text align","TableOperations")+":"));n=u.createElement("select");n.name=this.dialog.createId("textAlign");n.style.marginLeft=n.style.marginRight="0.5em";h.appendChild(n);this.inputs.styles.textAlign=n;e=["Left","Center","Right","Justify","-"];if(r=="td"){e.push("Char")}j=u.createElement("input");this.inputs.aux.textAlignChar=j;j.name=this.dialog.createId("textAlignChar");j.size="1";j.style.fontFamily="monospace";h.appendChild(j);for(var o=0;o<e.length;++o){var g=e[o];var t=g.toLowerCase();k=u.createElement("option");k.value=t;k.innerHTML=Xinha._lc(g,"TableOperations");k.selected=((d.style.textAlign.toLowerCase()==t)||(d.style.textAlign==""&&g=="-"));n.appendChild(k)}var p=j;function s(i){p.style.visibility=i?"visible":"hidden";if(i){p.focus();p.select()}}n.onchange=function(){s(this.value=="char")};s(n.value=="char");b=u.createElement("tr");a.appendChild(b);h=u.createElement("td");h.className="label";b.appendChild(h);h.innerHTML=Xinha._lc("Height","TableOperations")+":";h=u.createElement("td");b.appendChild(h);j=u.createElement("input");j.name=this.dialog.createId("height");j.type="text";j.value=Xinha.InlineStyler.getLength(d.style.height);j.size="5";this.inputs.styles.height=j;j.style.marginRight="0.5em";h.appendChild(j);n=u.createElement("select");n.name=this.dialog.createId("heightUnit");this.inputs.aux.heightUnit=n;k=u.createElement("option");k.innerHTML=Xinha._lc("percent","TableOperations");k.value="%";k.selected=/%/.test(d.style.height);n.appendChild(k);k=u.createElement("option");k.innerHTML=Xinha._lc("pixels","TableOperations");k.value="px";k.selected=/px/.test(d.style.height);n.appendChild(k);h.appendChild(n);n.style.marginRight="0.5em";h.appendChild(u.createTextNode(Xinha._lc("Vertical align","TableOperations")+":"));n=u.createElement("select");n.name=this.dialog.createId("verticalAlign");this.inputs.styles.verticalAlign=n;n.style.marginLeft="0.5em";h.appendChild(n);e=["Top","Middle","Bottom","Baseline","-"];for(var o=0;o<e.length;++o){var g=e[o];var t=g.toLowerCase();k=u.createElement("option");k.value=t;k.innerHTML=Xinha._lc(g,"TableOperations");k.selected=((d.style.verticalAlign.toLowerCase()==t)||(d.style.verticalAlign==""&&g=="-"));n.appendChild(k)}return l};Xinha.InlineStyler.prototype.createStyleFieldset=function(){var g=this.editor;var t=this.doc;var e=this.element;var o=t.createElement("fieldset");var d=t.createElement("legend");o.appendChild(d);d.innerHTML=Xinha._lc("CSS Style","TableOperations");var s=t.createElement("table");o.appendChild(s);s.style.width="100%";var a=t.createElement("tbody");s.appendChild(a);var c,h,l,p,m,f,r;c=t.createElement("tr");a.appendChild(c);h=t.createElement("td");c.appendChild(h);h.className="label";h.innerHTML=Xinha._lc("Background","TableOperations")+":";h=t.createElement("td");c.appendChild(h);l=t.createElement("input");l.name=this.dialog.createId("backgroundColor");l.value=Xinha._colorToRgb(e.style.backgroundColor);l.type="hidden";this.inputs.styles.backgroundColor=l;l.style.marginRight="0.5em";h.appendChild(l);new Xinha.colorPicker.InputBinding(l);h.appendChild(t.createTextNode(" "+Xinha._lc("Image URL","TableOperations")+": "));l=t.createElement("input");l.name=this.dialog.createId("backgroundImage");l.type="text";this.inputs.styles.backgroundImage=l;if(e.style.backgroundImage.match(/url\(\s*(.*?)\s*\)/)){l.value=RegExp.$1}h.appendChild(l);c=t.createElement("tr");a.appendChild(c);h=t.createElement("td");c.appendChild(h);h.className="label";h.innerHTML=Xinha._lc("FG Color","TableOperations")+":";h=t.createElement("td");c.appendChild(h);l=t.createElement("input");l.name=this.dialog.createId("color");l.value=Xinha._colorToRgb(e.style.color);l.type="hidden";this.inputs.styles.color=l;l.style.marginRight="0.5em";h.appendChild(l);new Xinha.colorPicker.InputBinding(l);l=t.createElement("input");l.style.visibility="hidden";l.type="text";h.appendChild(l);c=t.createElement("tr");a.appendChild(c);h=t.createElement("td");c.appendChild(h);h.className="label";h.innerHTML=Xinha._lc("Border","TableOperations")+":";h=t.createElement("td");c.appendChild(h);l=t.createElement("input");l.name=this.dialog.createId("borderColor");l.value=Xinha._colorToRgb(e.style.borderColor);l.type="hidden";this.inputs.styles.borderColor=l;l.style.marginRight="0.5em";h.appendChild(l);new Xinha.colorPicker.InputBinding(l);p=t.createElement("select");p.name=this.dialog.createId("borderStyle");var n=[];h.appendChild(p);this.inputs.styles.borderStyle=p;f=["none","dotted","dashed","solid","double","groove","ridge","inset","outset"];var b=e.style.borderStyle;if(b.match(/([^\s]*)\s/)){b=RegExp.$1}for(var r=0;r<f.length;r++){var u=f[r];m=t.createElement("option");m.value=u;m.innerHTML=u;if(u==b){m.selected=true}p.appendChild(m)}p.style.marginRight="0.5em";function k(x){for(var v=0;v<n.length;++v){var w=n[v];w.style.visibility=x?"hidden":"visible";if(!x&&(w.tagName.toLowerCase()=="input")){w.focus();w.select()}}}p.onchange=function(){k(this.value=="none")};l=t.createElement("input");l.name=this.dialog.createId("borderWidth");n.push(l);l.type="text";this.inputs.styles.borderWidth=l;l.value=Xinha.InlineStyler.getLength(e.style.borderWidth);l.size="5";h.appendChild(l);l.style.marginRight="0.5em";var q=t.createElement("span");q.innerHTML=Xinha._lc("pixels","TableOperations");h.appendChild(q);n.push(q);k(p.value=="none");if(e.tagName.toLowerCase()=="table"){c=t.createElement("tr");a.appendChild(c);h=t.createElement("td");h.className="label";c.appendChild(h);l=t.createElement("input");l.name=this.dialog.createId("borderCollapse");l.type="checkbox";this.inputs.styles.borderCollapse=l;l.id="f_st_borderCollapse";var u=(/collapse/i.test(e.style.borderCollapse));l.checked=u?1:0;h.appendChild(l);h=t.createElement("td");c.appendChild(h);var j=t.createElement("label");j.htmlFor="f_st_borderCollapse";j.innerHTML=Xinha._lc("Collapsed borders","TableOperations");h.appendChild(j)}return o};