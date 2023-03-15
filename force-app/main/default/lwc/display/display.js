import { LightningElement } from 'lwc';

export default class Display extends LightningElement {
  counter = 0;
  augmentor = 2;

  get options() {
    return [
        { label: '1', value: 1 },
        { label: '2', value: 2 },
    ];
  }
  
  handleAugmentorChange(event) {
    
    this.augmentor = event.target.value;
  }

  handleIncrement(event) {
    console.log('--target-'+event.target.value);
    console.log('--detail-'+event.detail);
    const operand = event.detail;
    this.counter += operand;
  }
  
  handleDecrement(event) {
    const operand = event.detail;
    this.counter -= operand;
  }
}