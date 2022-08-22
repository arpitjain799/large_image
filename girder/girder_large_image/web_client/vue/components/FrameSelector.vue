<script>
import Vue from 'vue';
import ChannelSelector from './ChannelSelector.vue';

export default Vue.extend({
    props: ['imageMetadata', 'frameUpdate'],
    components: { ChannelSelector },
    data() {
        return {
            currentFrame: 0,
            maxFrame: this.imageMetadata.frames.length - 1,
            modes: [
                { id: 0, name: 'Frame' },
                { id: 1, name: 'Axis' }
            ],
            currentModeId: 0,
            indices: [],
            indexInfo: {},
            hasChannels: false,
            compositeModes: [
                { id: 0, name: 'Single' },
                { id: 1, name: 'Composite' }
            ],
            currentCompositeModeId: 0,
            compositeChannelInfo: {},
            compositedFrames: [],
            // currentChannelInfo
            // Use an object to keep track of current channel info (color, etc.)
            // Use this to bind to controls. Read/write from the big list of channel
            // info when the current selection changes.
            currentChannelInfo: {
                channel: 0,
                low: 0,
                high: 0,
                color: null
            },
            allChannelInfo: {}
        };

    },
    computed: {
        nonChannelIndices() {
            return this.indices.filter((index) => index !== 'IndexC');
        },
        currentChannelName() {
            if (!this.indexInfo['IndexC']) {
                return '';
            }
            return this.imageMetadata.channels[this.indexInfo['IndexC'].current];
        }
    },
    watch: {
        currentCompositeModeId(newCompositeModeId) {
            if (newCompositeModeId === 0) {
                this.compositeChannelInfo = [];
                this.frameUpdate(this.currentFrame);
            } else if (newCompositeModeId === 1) {
                const frameName = this.imageMetadata.channels[this.currentFrame];
                this.compositeChannelInfo.push({
                    channel: frameName,
                    color: '#f00'
                });
                this.compositedFrames.push(frameName);
            }
        }
    },
    methods: {
        singleModeUpdateChannel(newChannel) {
            this.indexInfo['IndexC'].current = newChannel;
            let newCurrentFrame = 0;
            Object.keys(this.indexInfo).forEach((key) => {
                const info = this.indexInfo[key];
                newCurrentFrame += info.current * info.stride;
            });
            this.currentFrame = newCurrentFrame;
            this.frameUpdate(this.currentFrame);
        },
        compositeModeUpdateChannel(compositeChannelInfo) {
            console.log(compositeChannelInfo);
        },
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
        },
        toggleChannel(index) {
            console.log(index);
        },
        colorUpdated() {
            console.log('color updated');
        },
        getCurrentChannelName() {
            if (!this.indexInfo['IndexC']) {
                return '';
            }
            return this.imageMetadata.channels[this.indexInfo['IndexC'].current];
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
        if (this.imageMetadata.channels) {
            this.hasChannels = true;
            this.imageMetadata.channels.forEach((channel) => {
                this.compositeChannelInfo[channel] = {
                    enabled: false,
                    color: null,
                    min: null,
                    max: null,
                    channel: channel
                };
            });
            this.compositeChannelInfo[this.imageMetadata.channels[0]].enabled = true;
        }
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
            <channel-selector
                :channels="imageMetadata.channels"
                :channelMap="imageMetadata.channelmap"
                :initialChannelName="getCurrentChannelName()"
                @updateFrameSingle="singleModeUpdateChannel"
            >
            </channel-selector>
            <!--
            <div class="image-frame-index-slider image-frame-channel-slider">
                <div class="image-frame-slider">
                    <label for="IndexC">Channel: </label>
                    <input
                        type="number"
                        name="IndexC"
                        min="0"
                        :max="indexInfo['IndexC'].range - 1"
                        :value="indexInfo['IndexC'].current"
                        @input.prevent="updateFrameByAxes"
                    >
                    <input
                        class="image-frame-slider"
                        type="range"
                        min="0"
                        name="IndexC"
                        :max="indexInfo['IndexC'].range - 1"
                        :value="indexInfo['IndexC'].current"
                        :disabled="currentCompositeModeId === 1"
                        @change.prevent="updateFrameByAxes"
                    >
                    <div
                        class="image-frame-composite-options"
                    >
                        <select
                            v-model="currentCompositeModeId"
                            name="compositeMode"
                        >
                            <option
                                v-for="compositeMode in compositeModes"
                                :key="compositeMode.id"
                                :value="compositeMode.id"
                            >
                                {{ compositeMode.name }}
                            </option>
                        </select>
                    </div>
                </div>
                <div class="single-channel-advanced-controls">
                    <div class="channel-false-color-controls">
                        <label>
                            <input type="checkbox">
                            False color:
                        </label>
                        <input
                            type="text"
                            @change="colorUpdated()"
                        >
                    </div>
                </div>
            </div>
            <div
                v-for="index in nonChannelIndices"
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
                    :disabled="currentCompositeModeId === 1"
                    @input.prevent="updateFrameByAxes"
                >
                <input
                    class="image-frame-slider"
                    type="range"
                    min="0"
                    :name="index"
                    :max="indexInfo[index].range - 1"
                    :value="indexInfo[index].current"
                    :disabled="currentCompositeModeId === 1"
                    @change.prevent="updateFrameByAxes"
                >
                <div
                    class="image-frame-composite-options"
                >
                    <select
                        v-model="currentCompositeModeId"
                        name="compositeMode"
                    >
                        <option
                            v-for="compositeMode in compositeModes"
                            :key="compositeMode.id"
                            :value="compositeMode.id"
                        >
                            {{ compositeMode.name }}
                        </option>
                    </select>
                </div>
            </div>
            -->
        </div>
    </div>
</template>

<style scoped>
.image-frame-simple-control {
    border: 1px solid black;
    display: flex;
    flex-direction: row;
}

.image-frame-index-slider {
    border: 1px solid black;
    display: flex;
    flex-direction: column;
}

.image-frame-slider {
    display: flex;
    flex-direction: row;
}

.single-channel-advanced-controls {
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
