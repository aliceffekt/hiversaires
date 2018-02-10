"use strict";

class StudioDoor extends Door {
  constructor(id, fadeDuration) {
    super(id, fadeDuration);
  }

  setup() {
    super.setup();
    hiversaires.interface.flashVignette();
    hiversaires.stage.billboard("overlay").hidden = true;
    hiversaires.music.playEffect("action_DoorInit");

    if (this.isUnlocked) {
      hiversaires.setModifier("open");
    }
  }

  get isUnlocked() {
    return hiversaires.game.puzzleState.studio;
  }
}
