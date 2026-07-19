import React from 'react';

import styles from './index.module.scss';

const Component = () => {
  return (
    <div className={styles.frame7}>
      <div className={styles.statusBar}>
        <div className={styles.time2}>
          <p className={styles.time}>9:41</p>
        </div>
        <img src="../image/mgnspfm3-evk1iqt.svg" className={styles.levels} />
      </div>
      <div className={styles.contentArea}>
        <div className={styles.frame4}>
          <div className={styles.grabber} />
        </div>
        <div className={styles.frame}>
          <p className={styles.a}>􁜾</p>
        </div>
        <div className={styles.frame3}>
          <div className={styles.frame2}>
            <p className={styles.text}>当前课程</p>
            <p className={styles.text2}>语文</p>
          </div>
          <div className={styles.frame2}>
            <p className={styles.text}>剩余时间</p>
            <p className={styles.text2}>20:19</p>
          </div>
        </div>
        <div className={styles.progressBar}>
          <div className={styles.track}>
            <div className={styles.filled} />
          </div>
          <div className={styles.time3}>
            <p className={styles.a0900}>09:00</p>
            <p className={styles.a0900}>10:00</p>
          </div>
        </div>
        <div className={styles.frame6}>
          <div className={styles.frame5}>
            <div className={styles.frame1}>
              <p className={styles.text3}>状态</p>
              <div className={styles.frame22}>
                <div className={styles.frame32}>
                  <p className={styles.text3}>10</p>
                </div>
                <p className={styles.text4}>状态极佳</p>
              </div>
            </div>
            <img src="../image/mgnspfm3-a7ccugz.svg" className={styles.vector1} />
          </div>
          <div className={styles.frame5}>
            <div className={styles.frame1}>
              <p className={styles.text3}>状态</p>
              <div className={styles.frame22}>
                <div className={styles.frame32}>
                  <p className={styles.text3}>10</p>
                </div>
                <p className={styles.text4}>状态极佳</p>
              </div>
            </div>
            <img src="../image/mgnspfm3-a7ccugz.svg" className={styles.vector1} />
          </div>
        </div>
      </div>
    </div>
  );
}

export default Component;
