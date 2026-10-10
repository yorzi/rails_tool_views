#!/usr/bin/env node
import { execFileSync } from 'node:child_process';
const git=(...args)=>execFileSync('git',args,{encoding:'utf8',maxBuffer:16*1024*1024});
const args=process.argv.slice(2);
if (!(args.length===1 && args[0]==='--staged') && !(args.length===2 && args[0]==='--range' && !args[1].startsWith('-'))) {
  console.error('Usage: node scripts/check-progress-ledger.mjs --staged | --range <base>..<head>');process.exit(2);
}
const ledgerPath=p=>p==='docs/human/05_PROGRESS_LEDGER.md' || /^docs\/human\/progress\/[^/]+\.md$/.test(p);
const sections=diff=>[...diff.matchAll(/^\+### (WORK-\d{8}-\d{2,}) — .+$/gm)].map(m=>m[1]);
let failures=0;
const fail=s=>{console.error(`ERROR ${s}`);failures++;};
try {
  if (args[0]==='--staged') {
    const files=git('diff','--cached','--name-only').trim().split('\n').filter(Boolean);
    if (!files.length) fail('No staged change');
    const paths=files.filter(ledgerPath);
    const ids=paths.length?sections(git('diff','--cached','--unified=0','--',...paths)):[];
    if (ids.length!==1) fail('Stage exactly one new WORK section for this commit');
    else console.log(`Staged section: ${ids[0]}; commit with Work-ID: ${ids[0]}`);
  } else {
    const commits=git('rev-list','--reverse',args[1],'--').trim().split('\n').filter(Boolean);
    if (!commits.length) fail('Range contains no commits');
    const seen=new Set();
    for (const sha of commits) {
      const message=git('show','-s','--format=%B',sha);
      const trailers=git('show','-s','--format=%(trailers:only,unfold)',sha);
      const exemptions=[...trailers.matchAll(/^Ledger-Exempt: (topology-only|automation-metadata)$/gm)];
      const parents=git('show','-s','--format=%P',sha).trim().split(' ').filter(Boolean);
      const files=(parents.length?git('diff','--name-only',parents[0],sha,'--'):git('diff-tree','--root','--no-commit-id','--name-only','-r',sha)).trim().split('\n').filter(Boolean);
      if (exemptions.length===1) {
        if (exemptions[0][1]==='topology-only' && (parents.length<2 || files.length)) fail(`${sha}: topology-only requires an unchanged tree merge`);
        else console.log(`REVIEW exemption ${sha}: ${exemptions[0][1]} (requires semantic review)`);
        continue;
      }
      const ids=[...trailers.matchAll(/^Work-ID: (WORK-\d{8}-\d{2,})$/gm)].map(m=>m[1]);
      if (ids.length!==1) {fail(`${sha}: exactly one Work-ID trailer required`);continue;}
      const id=ids[0];
      if (seen.has(id)) fail(`${sha}: repeated Work ID ${id}`);seen.add(id);
      const paths=files.filter(ledgerPath);
      const diff=paths.length?(parents.length?git('diff','--unified=0',parents[0],sha,'--',...paths):git('show','--format=','--unified=0',sha,'--',...paths)):'';
      const added=sections(diff);
      if (added.length!==1 || added[0]!==id) fail(`${sha}: matching new ledger section missing or multiple sections added`);
      if (parents.length) {
        const prior=git('ls-tree','-r','--name-only',parents[0]).trim().split('\n').filter(ledgerPath);
        if (prior.some(path=>git('show',`${parents[0]}:${path}`).includes(`### ${id} — `))) fail(`${sha}: Work ID already exists in parent`);
      }
      console.log(`${sha.slice(0,8)} ${id} ${message.split('\n')[0]}`);
    }
  }
} catch(e) {fail(e.message);}
console.log(`${failures?'FAIL':'PASS'} commit-to-ledger linkage; review prose, claims and exemptions separately.`);
process.exit(failures?1:0);
