#!/usr/bin/env node
/**
 * 从 project-manifest.json 生成 MASTER_SPEC.md。
 *
 * 为什么存在：手工拼接的 MASTER_SPEC 副本一定会跟分册文档漂移。
 * MASTER_SPEC 仅为批准意图的阅读副本；实现进度由独立项目维护。
 *
 * 用法:
 *   node scripts/build-master-spec.mjs          生成
 *   node scripts/build-master-spec.mjs --check  校验是否最新（CI 用，不一致则退出码 1）
 */
import { readFileSync, writeFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const manifest = JSON.parse(readFileSync(join(root, 'project-manifest.json'), 'utf8'));
const OUT = join(root, 'MASTER_SPEC.md');
if (!manifest.spec_baseline?.version || !manifest.spec_baseline?.date ||
    !Array.isArray(manifest.documents) || !manifest.documents.length) {
  throw new Error('Manifest requires spec_baseline.version/date and documents');
}
if (new Set(manifest.documents).size !== manifest.documents.length ||
    manifest.documents.some(f => typeof f !== 'string' || !/^[\w./-]+$/.test(f) || f.split('/').includes('..') || f.startsWith('/') || f === 'MASTER_SPEC.md')) {
  throw new Error('documents must contain unique, safe, non-generated relative paths');
}

const header = `# ${manifest.project} — MASTER PRODUCT / TECHNICAL SPEC

> **本文件由脚本生成，请勿手工编辑。**
> 源文件是 \`project-manifest.json\` 中 \`documents\` 列出的各分册。
> 重新生成：\`node scripts/build-master-spec.mjs\`
>
> 版本 ${manifest.spec_baseline.version} — ${manifest.spec_baseline.date}
> 主体：${manifest.entity.legal_name}（${manifest.entity.jurisdiction}）

---

## 目录

${manifest.documents.map((f, i) => `${i + 1}. ${f}`).join('\n')}

---
`;

const body = manifest.documents.map((file) => {
  const raw = readFileSync(join(root, file), 'utf8').trimEnd();
  return `\n\n<!-- ==== SOURCE: ${file} ==== -->\n\n${raw}\n\n---\n`;
}).join('');

const output = header + body;

if (process.argv.includes('--check')) {
  let current = '';
  try { current = readFileSync(OUT, 'utf8'); } catch { /* missing */ }
  if (current !== output) {
    console.error('✗ MASTER_SPEC.md 已过期。请运行: node scripts/build-master-spec.mjs');
    process.exit(1);
  }
  console.log('✓ MASTER_SPEC.md 是最新的');
  process.exit(0);
}

writeFileSync(OUT, output);
const lines = output.split('\n').length;
console.log(`✓ 已生成 MASTER_SPEC.md — ${manifest.documents.length} 份文档, ${lines} 行`);
