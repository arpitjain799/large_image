<script>
import _ from 'underscore';
export default {
    props: ['channels', 'channelMap', 'initialChannelName'],
    emits: ['updateFrameSingle', 'updateFrameComposite'],
    data() {
        return {
            compositeChannelInfo: {},
            currentChannelFalseColorEnabled: false,
            currentChannelFalseColor: '',
            currentChannelMin: 0,
            currentChannelMax: 0,
            currentChannelNumber: this.channelMap[this.initialChannelName],
            modes: [
                { id: 0, name: 'Single' },
                { id: 1, name: 'Composite' }
            ],
            currentModeId: 0
        }
    },
    methods: {
        updateChannel() {
            const newChannelName = this.channels[this.currentChannelNumber];
            const newChannelInfo = this.compositeChannelInfo[newChannelName];
            this.currentChannelFalseColorEnabled = newChannelInfo.falseColorEnabled;
            this.currentChannelFalseColor = newChannelInfo.falseColor;
            this.currentChannelMin = newChannelInfo.min;
            this.currentChannelMax = newChannelInfo.max;

            if (this.currentModeId === 0) {
                Object.keys(this.compositeChannelInfo).forEach((channel) => {
                    this.compositeChannelInfo[channel].enabled = (channel === newChannelName);
                });
                const activeFrames = _.filter(this.compositeChannelInfo, (channel) => channel.enabled);
                console.log(activeFrames);
                this.$emit('updateFrameSingle', activeFrames);
            } else {
                this.$emit('updateFrameSingle', this.compositeChannelInfo);
            }
        },
        updateCurrentChannelOptions() {
            const channelName = this.channels[this.currentChannelNumber];
            this.compositeChannelInfo[channelName]['falseColorEnabled'] = this.currentChannelFalseColorEnabled;
            this.compositeChannelInfo[channelName]['falseColor'] = this.currentChannelFalseColor;
            this.compositeChannelInfo[channelName]['min'] = this.currentChannelMin;
            this.compositeChannelInfo[channelName]['max'] = this.currentChannelMax;
            this.updateChannel();
        }
    },
    watch: {
        currentChannelNumber(newVal, oldVal) {
            console.log({ newVal, oldVal });
        }
    },
    mounted() {
        this.channels.forEach((channel) => {
            this.compositeChannelInfo[channel] = {
                channelNumber: this.channelMap[channel],
                falseColorEnabled: false,
                falseColor: '',
                min: 0,
                max: 0,
                enabled: channel === this.initialChannelName,
            };
        });
        this.currentChannelNumber = this.channelMap[this.initialChannelName];
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
        <div class="false-color-controls">
            <label for="enableFalseColor">False color: </label>
            <input
                type="checkbox"
                name="enableFalseColor"
                v-model="currentChannelFalseColorEnabled"
                @change.prevent="updateCurrentChannelOptions"
            >
            <label for="colorStringEntry">Color: </label>
            <input
                type="text"
                name="colorStringEntry"
                :disabled="!currentChannelFalseColorEnabled"
                v-model="currentChannelFalseColor"
                @change.prevent="updateCurrentChannelOptions"
            >
            <label for="minValue">Min: </label>
            <input
                type="number"
                step="0.001"
                min="0"
                max="1"
                v-model="currentChannelMin"
                @change.prevent="updateCurrentChannelOptions"
            >
            <label for="minValue">Max: </label>
            <input
                type="number"
                step="0.001"
                min="0"
                max="1"
                v-model="currentChannelMax"
                @change.prevent="updateCurrentChannelOptions"
            >
        </div>
    </div>
</template>

<style scoped>
.single-index-frame-control {
    display: flex;
    flex-direction: column;
}

.slider-mode-controls, .false-color-controls {
    display: flex;
    flex-direction: row;
}

.false-color-controls > * {
    margin-left: 5px;
}

.channel-number-input {
    margin-left: 5px;
}

.single-index-slider {
    width: 30%;
}
</style>
