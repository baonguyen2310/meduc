/* Run the actual library controls against 90 cards, 18 schools and combined filters. */
const fs=require('node:fs'),vm=require('node:vm'),assert=require('node:assert/strict');
class Node {
  constructor(){this.hidden=false;this.value='';this.children=[];this.events={};this.dataset={};}
  append(child){this.children.push(child);}
  replaceChildren(){this.children=[];}
  setAttribute(){}
  addEventListener(name,fn){this.events[name]=fn;}
  scrollIntoView(){}
  focus(){}
  querySelector(selector){return selector.includes('first-child')?this.children[0]:this.children.at(-1);}
}
const input=new Node(),school=new Node(),count=new Node(),pagination=new Node();
const cards=Array.from({length:90},(_,i)=>Object.assign(new Node(),{dataset:{quizSchool:`Trường ${Math.floor(i/5)+1}`},querySelector:()=>({textContent:`Đề cuối kỳ ${i+1}`})}));
const holder={querySelectorAll:()=>cards,querySelector:s=>s.includes('filter-count')?count:s.includes('school')?school:pagination};
input.closest=()=>holder;
const source=fs.readFileSync(require('node:path').join(__dirname,'../templates/app01/assets/meduc-v2/classroom.js'),'utf8');
const block=source.slice(source.indexOf('  // Exam library:'),source.indexOf('  // The old FAQ'));
vm.runInNewContext(block,{$$:()=>[input],document:{createElement:()=>new Node()},reducedMotion:true});
const visible=()=>cards.map((c,i)=>c.hidden?null:i+1).filter(Boolean);
assert.deepEqual(visible(),[1,2,3,4,5,6,7,8,9,10]);
assert.equal(school.children.length,18);
for(let i=0;i<8;i++) pagination.children.at(-1).events.click();
assert.deepEqual(visible(),[81,82,83,84,85,86,87,88,89,90]);
assert.equal(pagination.children.at(-1).disabled,true);
school.value='Trường 2';school.events.change();
assert.deepEqual(visible(),[6,7,8,9,10]);assert.equal(pagination.hidden,true);
input.value='cuoi ky 9';input.events.input();assert.deepEqual(visible(),[9]);
input.value='không tồn tại';input.events.input();assert.equal(visible().length,0);assert.match(count.textContent,/Không tìm thấy/);
school.value='';school.events.change();input.value='';input.events.input();
assert.equal(visible().length,10);assert.equal(pagination.children[0].disabled,true);
console.log('90-exam pagination, school filtering, accent-insensitive search and empty/reset states passed.');
