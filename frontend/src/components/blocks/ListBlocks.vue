<template>
  <component :is="listTag" :class="listClass">
    <template v-for="(item, index) in (block.content || [])" :key="index">
      <template v-if="item.type === 'list_item'">
        <li class="mn-list-item">
          <template v-for="(child, ci) in (item.content || [])" :key="ci">
            <TextRenderer v-if="child.type === 'text'" :node="child as any" />
            <br v-else-if="child.type === 'soft_break'" />
            <component v-else :is="getBlockComponent(child.type)" :block="child" />
          </template>
        </li>
      </template>
      <template v-else-if="item.type === 'dt'">
        <dt class="mn-dt">
          <template v-for="(child, ci) in (item.content || [])" :key="ci">
            <TextRenderer v-if="child.type === 'text'" :node="child as any" />
          </template>
        </dt>
      </template>
      <template v-else-if="item.type === 'dd'">
        <dd class="mn-dd">
          <MirrorRenderer :blocks="item.content || []" />
        </dd>
      </template>
    </template>
  </component>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { MirrorBlockNode } from '@/stores/documentStore'
import TextRenderer from '@/components/TextRenderer.vue'
import MirrorRenderer from '@/components/MirrorRenderer.vue'
import { getBlockComponent } from './index'

const props = defineProps<{ block: MirrorBlockNode }>()

const listTag = computed(() => {
  switch (props.block.type) {
    case 'ordered_list': return 'ol'
    case 'dl': return 'dl'
    default: return 'ul'
  }
})

const listClass = computed(() => {
  switch (props.block.type) {
    case 'ordered_list': return 'mn-ordered-list'
    case 'dl': return 'mn-definition-list'
    default: return 'mn-bullet-list'
  }
})
</script>

<style scoped>
.mn-bullet-list { list-style-type: disc; padding-left: 1.5rem; margin-bottom: 1rem; }
.mn-ordered-list { list-style-type: decimal; padding-left: 1.5rem; margin-bottom: 1rem; }
.mn-definition-list { margin: 1rem 0; }
.mn-list-item { margin-bottom: 0.3rem; line-height: 1.65; color: var(--ebook-text); }
.mn-dt { font-weight: 600; color: var(--ebook-text-heading); margin-top: 1rem; }
.mn-dd { margin-left: 1.5rem; margin-bottom: 0.5rem; color: var(--ebook-text); line-height: 1.65; }
</style>
