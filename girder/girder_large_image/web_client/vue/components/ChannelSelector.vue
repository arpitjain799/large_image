<script>
import _ from 'underscore';
export default {
    props: ['channels', 'channelMap', 'initialChannelName'],
    emits: ['updateFrameSingle', 'updateFrameComposite'],
    data() {
        return {
            compositeChannelInfo: [],
            currentChannelInfo: {},
            currentChannelNumber: this.channelMap[this.initialChannelName],
            currentChannelName: this.initialChannelName,
            modes: [
                { id: 0, name: 'Single' },
                { id: 1, name: 'Composite' }
            ],
            currentModeId: 0
        }
    },
    methods: {
        updateChannel() {
            if (this.currentModeId === 0) {
                this.$emit('updateFrameSingle', this.currentChannelNumber);
            } else {
                this.$emit('updateFrameComposite', this.compositeChannelInfo);
            }
        }
    },
    mounted() {
        this.channels.forEach((channel) => {
            this.compositeChannelInfo.push({
                name: channel,
                color: null,
                min: 0,
                max: 0,
                enabled: false,
            });
        });
        this.currentChannelNumber = this.channelMap[this.currentChannelName];
    },
}

</script>

<template>
    <div class="single-index-frame-control">
        <div class="slider-mode-controls">
            <label for="channel">Channel: </label>
            <input
                class="channel-number-input"
                type="number"
                name="channel"
                min="0"
                :max="channels.length - 1"
                v-model="currentChannelNumber"
                @change.prevent="updateChannel"
            >
            <input
                class="single-index-slider"
                type="range"
                name="channelSlider"
                min="0"
                :max="channels.length -1"
                v-model="currentChannelNumber"
                @change.prevent="updateChannel"
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
    </div>
</template>

<style scoped>
.single-index-frame-control {
    display: flex;
    flex-direction: column;
}

.slider-mode-controls {
    display: flex;
    flex-direction: row;
}

.channel-number-input {
    margin-left: 5px;
}

.single-index-slider {
    width: 30%;
}
</style>
