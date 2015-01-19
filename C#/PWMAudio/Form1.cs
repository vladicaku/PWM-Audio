using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.IO.Ports;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace PWMAudio
{
    public partial class Form1 : Form
    {
        SerialPort serialPort;
        Thread thread;
        List<byte> data;
        String fileLocation;

        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            RefreshSerialPortList();
        }

        private void RefreshSerialPortList()
        {
            listBox1.Items.Clear();
            String[] ports = SerialPort.GetPortNames();
            if (ports != null)
            {
                foreach (String s in ports)
                {
                    listBox1.Items.Add(s);
                }
            }
            listBox1.SelectedIndex = -1;
            label1.Text = "";
        }

        private Image DrawGraph()
        {
            int reduce = 100;
            Image img = new Bitmap(data.Count / reduce, 225);
            Graphics g = Graphics.FromImage(img);
            Pen pen = new Pen(Color.Lime);
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            
            g.FillRectangle(new SolidBrush(Color.Black), 0, 0, img.Width, img.Height);
            int x = 0;
            int j = 0;
            int sum = 0;
            int old = 0;
            int prosek = 0;

            byte[] niza = data.ToArray();

            for (int i = 0; i < niza.Length; i++)
            {
                byte temp = niza[i];

                if (j < reduce)
                {
                    sum += temp;
                    j++;
                }
                else
                {
                    x++;
                    old = prosek;
                    prosek = sum / reduce;
                    g.DrawLine(pen, x - 1, 255 - old, x, 255 - prosek);
                    j = 0;
                    sum = 0;
                }
            }

            return img;
        }


        private void OpenFile()
        {
            BinaryReader reader = new BinaryReader(File.Open(fileLocation, FileMode.Open));
            int chunkID = reader.ReadInt32();
            int fileSize = reader.ReadInt32();
            int riffType = reader.ReadInt32();
            int fmtID = reader.ReadInt32();
            int fmtSize = reader.ReadInt32();
            int fmtCode = reader.ReadInt16();
            int channels = reader.ReadInt16();
            int sampleRate = reader.ReadInt32();
            int fmtAvgBPS = reader.ReadInt32();
            int fmtBlockAlign = reader.ReadInt16();
            int bitDepth = reader.ReadInt16();
            if (fmtSize == 18)
            {
                // Read any extra values
                int fmtExtraSize = reader.ReadInt16();
                reader.ReadBytes(fmtExtraSize);
            }

            int dataID = reader.ReadInt32();
            int dataSize = reader.ReadInt32();
            data = new List<byte>();

            // Add file name to the list
            String name = Path.GetFileName(fileLocation);
            for (int i = 0; i < name.Length; i++)
            {
                data.Add(Convert.ToByte(name[i]));
            }
            data.Add((byte)1);  // protocol bit - end

            
            for (int i = 0; i < dataSize; i++)
            {
                data.Add(reader.ReadByte());
            }
            reader.Close();
            
            // Set image
            panel1.AutoScroll = true;
            pictureBox1.SizeMode = PictureBoxSizeMode.AutoSize;
            pictureBox1.Image = DrawGraph();

            // Info
            lblSampleRate.Text = "Sample rate: " + sampleRate;
            lblBitRate.Text = "Bit rate: " + bitDepth;
            lblFileName.Text = "File name: " + Path.GetFileName(fileLocation);

        }

        private void CloseSerialPort()
        {
            if (serialPort != null && serialPort.IsOpen)
            {
                serialPort.Close();
            }
            serialPort = null;
        }

        private void button6_Click(object sender, EventArgs e)
        {
            RefreshSerialPortList();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            if (listBox1.SelectedItem != null)
            {
                CloseSerialPort();

                String portName = listBox1.SelectedItem.ToString();
                SerialPort temp = new SerialPort(portName);
                if (temp.IsOpen)
                {
                    MessageBox.Show(portName + " is not available. Try with different port.", "Error", MessageBoxButtons.OKCancel, MessageBoxIcon.Error);
                }
                else
                {
                    if (serialPort != null && serialPort.IsOpen)
                    {
                        serialPort.Close();
                    }
                    serialPort = new SerialPort(portName, 115200);
                    serialPort.StopBits = StopBits.One;
                    serialPort.Parity = Parity.None;
                    //serialPort.Open();
                    lblPort.Text = "Port: " + portName;
                }
            }
            //RefreshSerialPortList();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            lblPort.Text = "Port:";
            CloseSerialPort();
            RefreshSerialPortList();
        }

        private void listBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (listBox1.SelectedItem == null)
            {
                return;
            }

            SerialPort temp = new SerialPort(listBox1.SelectedItem.ToString());
            if (temp.IsOpen)
            {
                label1.Text = "Unavailable";
            }
            else
            {
                label1.Text = "Available";
            }
        }

        private void button3_Click(object sender, EventArgs e)
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();
            openFileDialog.Title = "Select .wav file";
            openFileDialog.Filter = "WAV Files (*.wav) | *.wav";
            if (openFileDialog.ShowDialog() == System.Windows.Forms.DialogResult.OK && openFileDialog.FileName != null)
            {
                fileLocation = openFileDialog.FileName;
                OpenFile();
            }
        }

        private void button4_Click(object sender, EventArgs e)
        {
            ThreadStart ts = new ThreadStart(Play);
            thread = new Thread(ts);
            thread.Start();
        }

        private void Play()
        {
            if (serialPort == null || serialPort.IsOpen)
            {
                MessageBox.Show("Please select Serial port.", "Error", MessageBoxButtons.OKCancel, MessageBoxIcon.Error);
                return;
            }
            else if(serialPort.IsOpen)
            {
                serialPort.Close();
            }

            if (serialPort.IsOpen)
            {
                MessageBox.Show("Serial port is in use,", "Error", MessageBoxButtons.OKCancel, MessageBoxIcon.Error);
                return;
            }

            serialPort.Open();
            byte[] niza = data.ToArray();
            serialPort.Write(niza, 0, niza.Length);
            serialPort.Close();
        }

        private void button5_Click(object sender, EventArgs e)
        {
            try
            {
                if (thread != null)
                {
                    thread.Suspend();
                }
            }
            catch (Exception ex)
            {
            }

            thread = null;

            if (serialPort != null && serialPort.IsOpen)
            {
                serialPort.Close();
            }
        }

        private void listBox1_MouseDoubleClick(object sender, MouseEventArgs e)
        {
            button1_Click(sender, e);
        }
    }
}
