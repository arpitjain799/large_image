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
            currentChannelEnabled: true,
            currentChannelNumber: this.channelMap[this.initialChannelName],
            modes: [
                { id: 0, name: 'Single' },
                { id: 1, name: 'Composite' }
            ],
            currentModeId: 0
        }
    },
    methods: {
        preventDisableChannel() { const numChannelsEnabled = _.reduce(Object.keys(this.compositeChannelInfo), (memo, channelKey) => {
                return memo + (this.compositeChannelInfo[channelKey].enabled ? 1 : 0);
            }, 0);
            return this.currentModeId === 1 && numChannelsEnabled === 1 && this.currentChannelEnabled;
        },
        updateChannel() {
            const newChannelName = this.channels[this.currentChannelNumber];
            const newChannelInfo = this.compositeChannelInfo[newChannelName];
            this.currentChannelFalseColorEnabled = newChannelInfo.falseColorEnabled;
            this.currentChannelFalseColor = newChannelInfo.falseColor;
            this.currentChannelMin = newChannelInfo.min;
            this.currentChannelMax = newChannelInfo.max;
            this.currentChannelEnabled = newChannelInfo.enabled;

            if (this.currentModeId === 0) {
                Object.keys(this.compositeChannelInfo).forEach((channel) => {
                    this.compositeChannelInfo[channel].enabled = (channel === newChannelName);
                });
                this.currentChannelEnabled = true;
                const activeFrames = _.filter(this.compositeChannelInfo, (channel) => channel.enabled);
                this.$emit('updateFrameSingle', activeFrames);
            } else {
                const activeFrames = _.filter(this.compositeChannelInfo, (channel) => channel.enabled);
                this.$emit('updateFrameSingle', activeFrames);
            }
        },
        updateCurrentChannelOptions() {
            const channelName = this.channels[this.currentChannelNumber];
            this.compositeChannelInfo[channelName]['falseColorEnabled'] = this.currentChannelFalseColorEnabled;
            this.compositeChannelInfo[channelName]['falseColor'] = this.currentChannelFalseColor;
            this.compositeChannelInfo[channelName]['min'] = this.currentChannelMin;
            this.compositeChannelInfo[channelName]['max'] = this.currentChannelMax;
            this.compositeChannelInfo[channelName]['enabled'] = this.currentChannelEnabled;
            this.updateChannel();
        }
    },
    watch: {
    },
    mounted() {
        this.channels.forEach((channel) => {
            this.compositeChannelInfo[channel] = {
                number: this.channelMap[channel],
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
            <label
                v-if="currentModeId === 1"
                for="enabled"
            >
                Enabled:
            </label>
            <input
                v-if="currentModeId === 1"
                type="checkbox"
                name="enable"
                :disabled="preventDisableChannel()"
                v-model="currentChannelEnabled"
                @change.prevent="updateCurrentChannelOptions"
            >
            <label for="enableFalseColor">False color: </label>
            <input
                type="checkbox"
                name="enableFalseColor"
                v-model="currentChannelFalseColorEnabled"
                @change.prevent="updateCurrentChannelOptions"
            >
            <label
                for="colorStringEntry"
                v-if="currentChannelFalseColorEnabled"
            >
                Color:
            </label>
            <input
                v-if="currentChannelFalseColorEnabled"
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
