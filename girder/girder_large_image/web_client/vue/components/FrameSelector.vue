<script>
import Vue from 'vue';

export default Vue.extend({
    props: ['imageMetadata', 'frameUpdate'],
    data() {
        return {
            currentFrame: 0,
            maxFrame: this.imageMetadata.frames.length - 1,
            modes: [
                { id: 0, name: 'Frame' },
                { id: 1, name: 'Axis' },
            ],
            indices: [],
            indexInfo: {},
            currentModeId: 0
        };
    },
    methods: {
        updateFrameByAxes(event) {
            const target = event.target;
            const name = target.name;
            const newValue = target.valueAsNumber;
            this.indexInfo[name].current = newValue;
            let newCurrentFrame = 0;
            Object.keys(this.indexInfo).forEach((key) => {
                const info = this.indexInfo[key];
                newCurrentFrame += info.current * info.stride;
            });
            this.currentFrame = newCurrentFrame;

            // attempt to call the outside method to update frame
            this.frameUpdate(this.currentFrame);
        },
        updateFrame(event) {
            // update 'current' property of frameInfo objects
            const target = event.target;
            const newFrame = target.valueAsNumber;

            Object.keys(this.indexInfo).forEach((key) => {
                this.indexInfo[key].current = Math.floor(
                    this.currentFrame / this.indexInfo[key].stride) % this.indexInfo[key].range;
            });
            this.frameUpdate(newFrame);
        }
    },
    mounted() {
        Object.keys(this.imageMetadata.IndexRange).forEach((indexName) => {
            this.indices.push(indexName);
            this.indexInfo[indexName] = {
                current: 0,
                range: this.imageMetadata.IndexRange[indexName],
                stride: this.imageMetadata.IndexStride[indexName]
            };
        });
    }
});
</script>

<template>
    <div class="image-frame-control">
        <div class="image-frame-simple-control">
            <label for="frame">Frame: </label>
            <input
                type="number"
                name="frame"
                min="0"
                :max="maxFrame"
                :disabled="currentModeId === 1"
                v-model="currentFrame"
                @input.prevent="updateFrame"
            >
            <input
                class="image-frame-slider"
                type="range"
                name="frameSlider"
                min="0"
                :max="maxFrame"
                :disabled="currentModeId === 1"
                v-model="currentFrame"
                @change.prevent="updateFrame"
            >
            <select
                v-model="currentModeId"
                name="mode"
            >
                <option
                    v-for="mode in modes"
                    :key="mode.id"
                    :value="mode.id"
                >
                    {{ mode.name }}
                </option>
            </select>
        </div>
        <div
            v-if="currentModeId === 1"
            class="image-frame-advanced-controls"
        >
            <div
                v-for="index in indices"
                :key="index"
                class="image-frame-index-slider"
            >
                <label :for="index">{{ index }}: </label>
                <input
                    type="number"
                    :name="index"
                    min="0"
                    :max="indexInfo[index].range - 1"
                    :value="indexInfo[index].current"
                    @input.prevent="updateFrameByAxes"
                >
                <input
                    class="image-frame-slider"
                    type="range"
                    min="0"
                    :name="index"
                    :max="indexInfo[index].range - 1"
                    :value="indexInfo[index].current"
                    @change.prevent="updateFrameByAxes"
                >
            </div>
        </div>
    </div>
</template>

<style scoped>
.image-frame-simple-control, .image-frame-index-slider {
    border: 1px solid black;
    display: flex;
    flex-direction: row;
}

.image-frame-simple-control > * {
    margin-right: 5px;
}

.image-frame-index-slider > * {
    margin-right: 5px;
}

.image-frame-slider {
    width: 30%;
}
</style>
