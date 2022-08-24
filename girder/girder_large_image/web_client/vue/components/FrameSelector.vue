<script>
import Vue from 'vue';
import ChannelSelector from './ChannelSelector.vue';
import IndexSelector from './IndexSelector.vue';

export default Vue.extend({
    props: ['imageMetadata', 'frameUpdate'],
    components: { ChannelSelector, IndexSelector },
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
            compositedFrames: {},
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
            }
        }
    },
    methods: {
        buildStyleArray() {
            const activeChannels = this.indexInfo['IndexC'].activeFrames;
            console.log(this.indexInfo['IndexC'].activeFrames);
            const styleArray = [];
            _.forEach(activeChannels, (channel) => {
                const styleEntry = {
                    frame: channel.number,
                };
                if (channel.falseColor) {
                    styleEntry['palette'] = channel.falseColor;
                }
                // styleEntry['min'] = 0 + 255 * channel.min;
                // styleEntry['max'] = 255 - 255 * channel.max
                styleArray.push(styleEntry);
            });
            return { bands: styleArray };
        },
        singleModeUpdateChannel(activeChannelInfo) {
            this.indexInfo['IndexC'].activeFrames = activeChannelInfo;
            const useStyle = (activeChannelInfo.length > 1
                              || activeChannelInfo[0].falseColorEnabled
                              || activeChannelInfo[0].min
                              || activeChannelInfo[0].max);
            if (useStyle) {
                const styleArray = this.buildStyleArray();
                this.frameUpdate(this.currentFrame, styleArray);
            } else {
                this.frameUpdate(activeChannelInfo[0].number);
            }
        },
        compositeModeUpdateChannel(compositeChannelInfo) {
            console.log(compositeChannelInfo);
        },
        updateFrameByAxes(event) {
            const activeChannelFrames = this.indexInfo['IndexC'].activeFrames;
            if (!activeChannelFrames) {
                // do the math
            } else {
                const useStyle = (activeChannelFrames.length > 1
                                || activeChannelFrames.falseColorEnabled
                                || activeChannelFrames.min
                                || activeChannelFrames.max);
                if (!useStyle) {
                    // do the math
                } else {
                    const styleArray = this.buildStyleArray();
                }
            }
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
                stride: this.imageMetadata.IndexStride[indexName],
                activeFrames: []
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
            <div v-if="currentModeId === 1">
                <div
                    v-for="index in nonChannelIndices"
                    :key="index"
                >
                    <index-selector
                        :indexName="index"
                        :range="indexInfo[index].range"
                        :stride="indexInfo[index].stride"
                        :initialFrame="indexInfo[index].current"
                        @updateFrame="updateFrameByAxes"
                    >
                    </index-selector>
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped>
.image-frame-simple-control {
    display: flex;
    flex-direction: row;
}

.image-frame-index-slider {
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
