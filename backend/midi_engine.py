"""
MIDI generation engine for extracting structured MIDI data from LLM responses
and generating downloadable .mid files.
"""

import json
import os
import re
from typing import Optional, Tuple
from uuid import uuid4

import mido


def extract_and_generate_midi(
    response_text: str,
    output_dir: str = "static/midi"
) -> Tuple[str, Optional[str]]:
    """
    Extract MIDI data from LLM response and generate a .mid file.
    
    Args:
        response_text: The raw text response from the LLM
        output_dir: Directory to save generated MIDI files
        
    Returns:
        Tuple of (clean_text, midi_filename) where midi_filename is None if no MIDI found
    """
    # Regex to find content between <MIDI_DATA> tags
    match = re.search(r"<MIDI_DATA>(.*?)</MIDI_DATA>", response_text, re.DOTALL)
    
    midi_filename = None
    clean_text = response_text

    if match:
        json_str = match.group(1).strip()
        try:
            data = json.loads(json_str)
            
            # Create MIDI file
            mid = mido.MidiFile()
            
            # Set ticks per beat (standard resolution)
            ticks_per_beat = 480
            mid.ticks_per_beat = ticks_per_beat
            
            # Get tempo (BPM) and convert to microseconds per beat
            bpm = data.get("tempo", 120)
            tempo = mido.bpm2tempo(bpm)
            
            # Process each track
            for track_data in data.get("tracks", []):
                track = mido.MidiTrack()
                mid.tracks.append(track)
                
                # Add tempo meta message to first track
                if len(mid.tracks) == 1:
                    track.append(mido.MetaMessage('set_tempo', tempo=tempo))
                    
                    # Add time signature if provided
                    time_sig = data.get("time_signature", [4, 4])
                    if len(time_sig) >= 2:
                        track.append(mido.MetaMessage(
                            'time_signature',
                            numerator=time_sig[0],
                            denominator=time_sig[1]
                        ))
                
                # Add track name
                instrument_name = track_data.get("instrument", "Track")
                track.append(mido.MetaMessage('track_name', name=instrument_name))
                
                # Collect all note events (note_on and note_off)
                events = []
                for note in track_data.get("notes", []):
                    pitch = int(note.get("pitch", 60))
                    velocity = int(note.get("velocity", 100))
                    start_time = float(note.get("start_time", 0))
                    duration = float(note.get("duration", 1.0))
                    
                    # Calculate tick positions
                    start_tick = int(start_time * ticks_per_beat)
                    end_tick = int((start_time + duration) * ticks_per_beat)
                    
                    # Note On event
                    events.append({
                        "type": "note_on",
                        "note": pitch,
                        "velocity": velocity,
                        "time": start_tick
                    })
                    
                    # Note Off event
                    events.append({
                        "type": "note_off",
                        "note": pitch,
                        "velocity": 0,
                        "time": end_tick
                    })
                
                # Sort events by absolute time
                events.sort(key=lambda x: (x["time"], x["type"] == "note_on"))
                
                # Convert to delta times and write to track
                last_time = 0
                for event in events:
                    delta_time = event["time"] - last_time
                    track.append(mido.Message(
                        event["type"],
                        note=event["note"],
                        velocity=event["velocity"],
                        time=delta_time
                    ))
                    last_time = event["time"]
                
                # End of track
                track.append(mido.MetaMessage('end_of_track', time=0))
            
            # Save the MIDI file
            filename = f"generated_{uuid4().hex[:8]}.mid"
            os.makedirs(output_dir, exist_ok=True)
            midi_path = os.path.join(output_dir, filename)
            mid.save(midi_path)
            midi_filename = filename
            
            # Clean up the response text by replacing MIDI_DATA block with indicator
            clean_text = re.sub(
                r"<MIDI_DATA>.*?</MIDI_DATA>",
                "\n🎹 **[MIDI File Generated]**\n",
                response_text,
                flags=re.DOTALL
            )
            
        except json.JSONDecodeError as e:
            print(f"MIDI JSON Parse Error: {e}")
        except Exception as e:
            print(f"MIDI Generation Error: {e}")

    return clean_text, midi_filename
