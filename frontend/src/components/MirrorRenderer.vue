<template>
  <div class="content-blocks">
    <template v-for="(block, index) in blocks" :key="index">
      <MirrorRenderer v-if="block.type === 'doc'" :blocks="block.content || []" />
      <TextRenderer v-else-if="block.type === 'text'" :node="block as any" />
      <ClauseBlock v-else-if="isSectionType(block.type)" :block="block" />
      <br v-else-if="block.type === 'soft_break'" />
      <component v-else :is="getBlockComponent(block.type)" :block="block" />
    </template>
  </div>
</template>

<script setup lang="ts">
import type { MirrorBlockNode, MirrorTextNode } from '@/stores/documentStore'
import ClauseBlock from './blocks/ClauseBlock.vue'
import TextRenderer from './TextRenderer.vue'
import { getBlockComponent } from './blocks'
import { isSectionType } from '@/utils/typeMetadata'

defineProps<{
  blocks: (MirrorBlockNode | MirrorTextNode)[]
}>()
</script>
