import React from 'react';
import StageExtras from './StageExtras';

export default storybook => {
  storybook
    .storiesOf('StageExtras', module)
    .addWithInfo(
      'default',
      'This is the StageExtras component.',
      () => (
        <StageExtras
          stageNumber={1}
          nextLevelPath="#"
          bonusLevels={[
            {id: 0, type: 'Blockly', name: 'Sample Bonus Level'},
            {id: 1, type: 'Blockly', name: 'Another Bonus Level'},
          ]}
        />
      )
    );
};
